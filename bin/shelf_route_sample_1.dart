/**
 * Simple server code utilizing shelf_route middleware.
 * Access the server using :
 * 'http://localhost:8080/bookstore/map/tokyo?detail=false'
 * Path parameters and query parameters will be set in the context as:
 *   shelf_path.parameters : {category: map, area: tokyo, detail: false}
 * July, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart' as route;
import 'dart:async';
import 'utilities.dart' as util;

/**
 * Siple request dump handler
 */
dynamic requestDumpHandler(shelf.Request request) {
    var completer = new Completer();
    String data;
    util.reqInfo(request).then((sb){
      data = sb.toString();               // return plain text
//    print(data);                        // console out for debugging
      data = util.createHtmlResponse(sb); // or, return html text
      completer.complete(new shelf.Response.ok(data));
    });
  return completer.future;
}

/**
 * create and set the router
 */
var router = route.router()
    ..add('/bookstore/{category}/{area}{?detail}', ['GET'], requestDumpHandler,
        middleware: shelf.logRequests());

/**
 * Start server listening on port 8080
 */
void main() {
  io.serve(router.handler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}