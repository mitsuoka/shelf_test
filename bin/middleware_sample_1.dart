/**
 * Sample middleware code showing how to hand modified request to the innerHandler.
 * call this server as : http://localhost/test
 * July, 2014 : first version
 * April, 2019 : made Dart 2 compliant
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'utilities.dart' as util;
import 'dart:async';

/**
 * Handler to dump out a shelf request object.
 * Returns Future<shelf.Response> object.
 */
Future<shelf.Response> requestDump(shelf.Request request) async {
  String data;
  StringBuffer sb = await util.reqInfo(request);
  data = sb.toString(); // return plain text
  print(data); // console out for debugging
  data = util.createHtmlResponse(sb); // or, return html text
  return shelf.Response.ok(data, headers: {"Content-Type": "text/html"});
}

/**
 * Middleware to modify incoming request and hands it to the innerHandler.
 */
shelf.Middleware myMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      return innerHandler(modifyRequest(request));
    };
  };
}

/**
 * Small function that modifies an incoming request.
 */
shelf.Request modifyRequest(shelf.Request request) {
  return request.change(context: {'testContextData': 'added by myMiddleware'});
}

/**
 * Compose a set of Middleware and a Handler.
 */
var myHandler = const shelf.Pipeline()
    .addMiddleware(myMiddleware())
    .addHandler(requestDump);

/**
 * Listen on port 8080
 */
void main() async {
  var server = await io.serve(myHandler, '127.0.0.1', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
