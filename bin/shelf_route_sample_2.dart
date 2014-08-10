/**
 * Simple sample application that utilizes shelf_route middleware.
 * Access this server like:
 *  http://localhost:8080/route (log-in page of the service)
 *  http://localhost:8080/favicon.ico (favicon)
 *  http://localhost:8080/images/DartLogo.jpg (static files)
 * userId path parameter is used to maintain the user session.
 * August, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart' as static;
import 'package:shelf_route/shelf_route.dart' as route;
import 'utilities.dart' as util;
import 'dart:async';
import 'dart:math';

final SERVICE = '/route';
var service = new Service();
var staticHandler = new StaticHandler();
final LOG_IN_PAGE = '/LoginPage.html';
final RE_ENTER_PAGE = '/ReEnterPage.html';


/**
 * create and set the router
**/
var router = route.router()
    ..add('${SERVICE}/{userId}/{page}', ['GET', 'POST'], service.doService,
        middleware: shelf.logRequests())
    ..add('${SERVICE}', ['GET'], staticHandler.doHandling)     // log in page
    ..add('/{file}', ['GET'], staticHandler.doHandling)        // static file includes favicon
    ..add('/{path}/{file}', ['GET'], staticHandler.doHandling);// static file


/**
 * Listen on port 8080
 */
void main() {
  io.serve(router.handler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}


/**
 * Service process class
 */
class Service {

  Map userTable = {};  // {userId : userState}
  Map userState = {};  // {userState : {userName:, password:, page:, ...}
  String userId;
  Map queries;
  var loginState;
  static const NEW_USER = 0;
  static const PW_OK = 1;
  static const PW_FAIL = 2;
  static const SESSION_TIMEOUT = 20;

  //doService handler
  dynamic doService(shelf.Request request) {
    var completer = new Completer.sync();
    request.readAsString().then((data){
      queries = Uri.splitQueryString(data);
//      print('queries : $queries');          // for debug
//      print('contxt : ${request.context}'); // for debug
      // process requests from login page
      if (route.getPathParameter(request,'page') == 'login') {
        userId = processLogin(request);
        if (loginState == PW_FAIL) {
          completer.complete(new shelf.Response.movedPermanently('/ReEnterPage.html'));
        }
        else {
          userTable[userId]['lastVisitedTime'] = new DateTime.now();
          completer.complete(new shelf.Response.ok(getHtml()));
        }
      }
      // process requests from transition page n
      else {
        userId = route.getPathParameter(request,'userId');
        var fromPage = int.parse(route.getPathParameter(request,"page"));
        if (queries['submit'] == 'End'){
          userTable[userId]['page'] = 1; // reset page
          completer.complete(new shelf.Response.movedPermanently('/route'));
        }
        else if (fromPage != userTable[userId]['page']){ // collided by two browsers
          completer.complete(new shelf.Response.movedPermanently('/route'));
        }
        else if (new DateTime.now().difference(userTable[userId]['lastVisitedTime'])
                                   .inSeconds > SESSION_TIMEOUT) {
          completer.complete(new shelf.Response.movedPermanently('/TimedOutPage.html'));
        }
        else if (queries['submit'] == 'Back') {
          if (fromPage != 1) userTable[userId]['page'] = --fromPage;
          userTable[userId]['lastVisitedTime'] = new DateTime.now();
          completer.complete(new shelf.Response.ok(getHtml()));
        }
        else {
          if (fromPage != 10)  userTable[userId]['page'] = ++fromPage;
          userTable[userId]['lastVisitedTime'] = new DateTime.now();
          completer.complete(new shelf.Response.ok(getHtml()));
        }
      }
    });
    return completer.future;
  }

  String processLogin(shelf.Request request){
    // see if the user exists in the table
    var exists= false;
    userTable.forEach((key, value){
      if (value['userName'] == queries['name']) {
        exists = true;
        userId = key;
        }
      });
    if (exists) { // existing user, check password
      if (userTable[userId]['password'] == queries['pwd']){
        loginState = PW_OK;
 //     userTable[userId]['page'] = 1;
        return userId;
      }
      else {
        loginState = PW_FAIL;
        return userId;
      }
    }
    else {   // new user
      do {   //give new id
        userId = new Random().nextInt(99999).toString();
      } while (userTable[userId] != null);
      userState = {'userName': queries['name'], 'password': queries['pwd'],
                   'page': 1, 'firstVisitedTime': new DateTime.now()};
      userState['lastVisitedTime'] = userState['firstVisitedTime'];
      userTable[userId] = userState;
      loginState = NEW_USER;
//    print('userTable : $userTable'); //for debug
      return userId;
    }
  }

  //get HTML string
  String getHtml() {
    int page = userTable[userId]['page'];
    String data = '''<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>shelf_route_test_2</title>
  </head> 
  <body>   
    *** shelf_route test ***
    <br><br>Hi ${userTable[userId]['userName']},
    <br>You are on the page $page.
    <br>Your session will be expired in $SESSION_TIMEOUT seconds.
    <br><br>
    <form method="post" action="/route/${userId}/${page}">
      <input type="submit" value="Back" name="submit">&nbsp;
      <input type="submit" value="End" name="submit">&nbsp;
      <input type="submit" value="Next" name="submit" autofocus>
    </form>
    <br>Your profile:''';
    var lines = '<br>&nbsp; userId : $userId';
    for (var key in userTable[userId].keys) {
      lines = lines + '<br>&nbsp; $key : ${userTable[userId][key]}';
    }
    return data + lines + ''' </body>
</html>''';
  }
}


/**
 * Static file handler class.
 * Returns requested files only in the /resources directory.
 * Returns the front page for the request with path == '${SERVICE}'
 * Note: You cannot hand the request directly to the shelf_static handler.
 */
class StaticHandler{
  dynamic doHandling(shelf.Request request)  {
    var path = request.requestedUri.path;
    print('staticHandler : requestedUri.path = $path');      // for debugging
    if (request.method == 'GET' && path == '${SERVICE}')     // front page
          return staticHandler(createRequest(request, LOG_IN_PAGE));
    else return staticHandler(createRequest(request, path)); // static files
  }

  // create new request with newPath
  shelf.Request createRequest(shelf.Request request, [newPath = '']) {
    var uri = request.requestedUri;
    return new shelf.Request('GET', new Uri(scheme: uri.scheme, userInfo: uri.userInfo,
        host: uri.host, port: uri.port, path: newPath, query: uri.query));
  }

  // staticHandler
  var staticHandler = static.createStaticHandler('../resources');
}



/**
 * Siple request dump handler for debugging
 */
dynamic reqDumpHandler(shelf.Request request) {
var completer = new Completer();
String data;
util.reqInfo(request).then((sb){
//  data = sb.toString();               // return plain text
//  print(data);                        // console out for debugging
 data = util.createHtmlResponse(sb); // or, return html text
 completer.complete(new shelf.Response.ok(data));
});
return completer.future;
}