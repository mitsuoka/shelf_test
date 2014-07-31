/**
 * Very simple sample handler
 * Access this server like: http://localhost:8080/
 * July, 2014 : first version
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

/**
 * Siple echo handler
 * Returns shelf.Response object.
 */
dynamic myHandler(shelf.Request request) =>
  new shelf.Response.ok('Hello from handler_sample_1.');

/**
 * Listen on port 8080
 */
void main() {
  io.serve(myHandler, '127.0.0.1', 8080).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
  });
}