/**
 * Simple sample handler that dumps out incoming request for proper analysis.
 * Access this server like: http://localhost:8080/
 * July, 2014 : first version
 * April 2019 : made Dart 2 compliant
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart' as static_handler;
import 'utilities.dart' as util;
import 'dart:async';

/**
 * Simple request dump handler
 */
Future<shelf.Response> myHandler(shelf.Request request) async {
  var path = request.requestedUri.path;
  if (path == '/' || path == '/favicon.ico' || path == '') {
    print('* static file request ${request.requestedUri.path} arrived');
    return staticHandler(request);
  } else {
    print('* request_dump request arrived');
    String data;
    StringBuffer sb =  await util.reqInfo(request);
    data = sb.toString(); // return plain text
    print(data); // console out for debugging
    data = util.createHtmlResponse(sb); // or, return html text
    return shelf.Response.ok(data, headers:{"Content-Type":"text/html"});
  }
}

/**
 * staticHandler
 * show front page or return favicon.ico
 */
var staticHandler = static_handler.createStaticHandler('resources',
    defaultDocument: 'ShelfRequestDump.html');

/**
 * Listen on port 8080
 */
void main() async {
  var server = await io.serve(myHandler, '127.0.0.1', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
