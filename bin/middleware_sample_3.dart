/**
 * Sample middleware code showing how to modify innerHandler's response.
 * Call this server like 'http://localhost:8080/123'.
 * July, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'dart:async';

/**
 * Simple handler to return single line text.
 */
shelf.Response simpleHandler(shelf.Request request) {
  return new shelf.Response.ok('Response for "${request.requestedUri}" from simpleHandler.');
}

/**
 * Middleware to modify incomming request and hands it to the innerHandler.
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
Future<shelf.Response> modifyResponse(shelf.Response response){
  var completer = new Completer();
  var newBody =
    'Time : ${new DateTime.now().toString().substring(11)} ... added by myMiddleware.';
  response.readAsString().then((data){
    newBody = '${data}\n${newBody}';
    completer.complete(new shelf.Response.ok(newBody, headers: response.headers));
    });
  return completer.future;
}

/**
 * Compose a set of Middlewares and a Handler.
 */
var myHandler = const shelf.Pipeline()
    .addMiddleware(myMiddleware())
    .addHandler(simpleHandler);

/**
 * Listen on port 8080
 */
void main() {
  io.serve(myHandler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}