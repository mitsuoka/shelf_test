/**
 * Utilities
 */

library utilities;

import 'package:shelf/shelf.dart' as shelf;
import 'dart:async';

//
// Create request dump text as Future<StringBuffer>
//
Future reqInfo(shelf.Request request) async {
  var sb =
      new StringBuffer('''Available shelf.request data for this HTTP request:
shelf.request.canHijack : ${request.canHijack}
shelf.request.contentLength : ${request.contentLength}
shelf.request.encoding : ${request.encoding}
shelf.request.ifModifiedSince : ${request.ifModifiedSince}
shelf.request.method : ${request.method}
shelf.request.mimeType : ${request.mimeType}
shelf.request.protocolVersion : ${request.protocolVersion}
shelf.request.url : ${request.url.toString()}
shelf.request.requestedUri : ${request.requestedUri}
shelf.request.requestedUri.path : ${request.requestedUri.path}
''');
  sb.write('''shelf.request.requestedUri.queryParameters :
''');
  request.requestedUri.queryParameters.forEach((key, value) {
    sb.write('  ${key} : ${value}\n');
  });
  sb.write('''shelf.request.context :
''');
  request.context.forEach((key, value) {
    sb.write('  ${key} : ${value}\n');
  });
  sb.write('''shelf.request.headers :
''');
  request.headers.forEach((key, value) {
    sb.write('  ${key} : ${value}\n');
  });
  if (request.method == 'POST') {
    var bodyString = await request.readAsString();
    sb.write('''request body String data :
  ''' +
        bodyString +
        "\n");
    return sb;
  } else
    return sb;
}

//
// create html response text
//
String createHtmlResponse(StringBuffer rawText) {
  var htmlRes = '''<html>
  <head>
    <title>ShelfRequestDump</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body>
    <H1>Shelf Request Dump</H1>
    <pre>${makeSafe(rawText).toString()}
    </pre>
  </body>
</html>
''';
  return htmlRes;
}

//
// Hex dump List<int> data
//
StringBuffer hexDump(StringBuffer sb, List<int> data) {
  sb.write("\n hexa dump:");
  int lines = data.length ~/ 32;
  int lastLineBytes = data.length % 32;
  for (int l = 0; l < lines; l++) {
    dumpLine(sb, data, l, 32);
  }
  if (lastLineBytes != 0) dumpLine(sb, data, lines, lastLineBytes);
  return sb;
}

StringBuffer dumpLine(StringBuffer sb, List<int> data, int line, int col) {
  sb.write('\n');
  for (int c = 0; c < col; c++) {
    int byte = data[line * 32 + c];
    int n = byte ~/ 16;
    if (n > 9) n = n + 7;
    sb.write(' ' + new String.fromCharCode(n + 48));
    n = byte & 15;
    if (n > 9) n = n + 7;
    sb.write(new String.fromCharCode(n + 48));
  }
  sb.write(' ');
  for (int c = 0; c < col; c++) {
    int byte = data[line * 32 + c];
    if (byte < 32) byte = 46;
    if (byte > 126) byte = 46;
    sb.write(new String.fromCharCode(byte));
  }
  return sb;
}

//
// make safe string buffer data as HTML text
//
StringBuffer makeSafe(StringBuffer b) {
  var s = b.toString();
  b = new StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (s[i] == '&') {
      b.write('&amp;');
    } else if (s[i] == '"') {
      b.write('&quot;');
    } else if (s[i] == "'") {
      b.write('&#x27;');
    } else if (s[i] == '<') {
      b.write('&lt;');
    } else if (s[i] == '>') {
      b.write('&gt;');
    } else if (s[i] == '/') {
      b.write('&#x2F;');
    } else
      b.write(s[i]);
  }
  return b;
}
