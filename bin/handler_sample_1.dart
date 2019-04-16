/**
 * Very simple sample handler
 * Access this server like: http://localhost:8080/test
 * July,  2014 : first version
 * April, 2019 : made Dart 2 compliant
 */

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

/**
 * Simple echo handler
 * Returns shelf.Response object.
 */
shelf.Response myHandler(shelf.Request request) =>
    new shelf.Response.ok('Hello from handler_sample_1.');

/**
 * Listen on port 8080
 */
void main() async {
  var server = await io.serve(myHandler, '127.0.0.1', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
