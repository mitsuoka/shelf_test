/**
 * Sample middleware code that returns response directly.
 * opening 'http://localhost:8080/middleware' will cause direct return.
 * July, 2014 : first version
 * April 2019 : made Dart 2 compliant
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

/**
 * Simple handler to return single line text.
 */
shelf.Response simpleHandler(shelf.Request request) {
  return new shelf.Response.ok(
      'Response for "${request.requestedUri}" from simpleHandler.');
}

/**
 * Middleware that returns response for '/middleware' request.
 */
shelf.Middleware myMiddleware =
    shelf.createMiddleware(requestHandler: (shelf.Request request) {
  if (request.requestedUri.path == '/middleware') {
    // direct response
    return new shelf.Response.ok(
        'Response for "${request.requestedUri}" from myMiddleware.');
  } else
    return null; // call inner handler
});

/**
 * Compose a set of Middleware and a Handler.
 */
var myHandler = const shelf.Pipeline()
    .addMiddleware(myMiddleware)
    .addHandler(simpleHandler);

/**
 * Listen on port 8080
 */
void main() async {
  var server = await io.serve(myHandler, '127.0.0.1', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
