/**
 * Sample middleware code showing how to hand modified request to the innerHandler.
 * July, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'utilities.dart' as util;
import 'dart:async';

/**
 * Handler to dump out a shelf request object.
 * Returns Future<shelf.Response> object.
 */
Future<shelf.Response> requestDump(shelf.Request request) {
  var completer = new Completer();
  String data;
  util.reqInfo(request).then((sb){
      data = sb.toString();               // return plain text
//    print(data);                        // console out for debugging
//    data = util.createHtmlResponse(sb); // or, return html text
    completer.complete(new shelf.Response.ok(data));
  });
  return completer.future;
}

/**
 * Middleware to modify incomming request and hands it to the innerHandler.
 */
shelf.Middleware myMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      return innerHandler(modifyRequest(request));
    };
  };
}

/**
 * Small function that modifies an incomming request.
 */
shelf.Request modifyRequest(shelf.Request request){
  var newContext = {'testContextData': 'added by myMiddleware'};
  if (request.context != null) newContext.addAll(request.context);
  return request.change(context: newContext);
}

/**
 * Compose a set of Middlewares and a Handler.
 */
var myHandler = const shelf.Pipeline()
    .addMiddleware(myMiddleware())
    .addHandler(requestDump);

/**
 * Listen on port 8080
 */
void main() {
  io.serve(myHandler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}
