/**
 * Sample middleware code showing how to modify innerHandler's response.
 * Call this server like 'http://localhost:8080/123'.
 * July, 2014 : first version
 * April 2019 : made Dart 2 compliant
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'dart:async';

/**
 * Simple handler to return single line text.
 */
shelf.Response simpleHandler(shelf.Request request) {
  return new shelf.Response.ok(
      'Response for "${request.requestedUri}" from simpleHandler.');
}

/**
 * Middleware to modify incoming request and hands it to the innerHandler.
 * Returns new Future<shelf.Response> object.
 */
shelf.Middleware myMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      return new Future.sync(() => innerHandler(request))
          .then((shelf.Response response) {
        return modifyResponse(response);
      });
    };
  };
}

/**
 * Small function that modifies an outgoing response.
 */
Future<shelf.Response> modifyResponse(shelf.Response response) async {
  var newBody =
      'Time : ${new DateTime.now().toString().substring(11)} ... added by myMiddleware.';
  var data = await response.readAsString();
  newBody = '${data}\n${newBody}';
  return shelf.Response.ok(newBody, headers: response.headers);
}

/**
 * Compose a set of Middleware and a Handler.
 */
var myHandler = const shelf.Pipeline()
    .addMiddleware(myMiddleware())
    .addHandler(simpleHandler);

/**
 * Listen on port 8080
 */
void main() async {
  var server = await io.serve(myHandler, '127.0.0.1', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}