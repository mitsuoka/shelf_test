/**
 * Simple sample handler that dumps out incoming request for proper analysis.
 * Access this server like: http://localhost:8080/
 * July, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart' as static;
import 'utilities.dart' as util;
import 'dart:async';

/**
 * Siple request dump handler
 */
dynamic myHandler(shelf.Request request) {
  if(request.requestedUri.path == '/' || request.requestedUri.path == '/favicon.ico') {
    // show front page or return favicon.ico
    return staticHandler(request);
  }
  else {
    var completer = new Completer();
    String data;
    util.reqInfo(request).then((sb){
      data = sb.toString();               // return plain text
      print(data);                        // console out for debugging
      data = util.createHtmlResponse(sb); // or, return html text
      completer.complete(new shelf.Response.ok(data));
    });
  return completer.future;
  }
}

/**
 * staticHandler
 */
var staticHandler = static.createStaticHandler('../resources',
    defaultDocument: 'ShelfRequestDump.html');

/**
 * Listen on port 8080
 */
void main() {
  io.serve(myHandler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}