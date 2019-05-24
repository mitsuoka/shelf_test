# shelf_test

**shelf\_test** is a set of **Dart 2 compliant** sample servers for development of
server applications utilizing [shelf web server middleware](https://pub.dartlang.org/packages/shelf)
pub package.

This repository consists of following server codes.

- **handler\_sample\_1.dart** : Very simple sample echo server handler.
 Access this server like: http://localhost:8080/test

- **handler\_sample\_2.dart** :  Simple sample handler that dumps out incoming request for proper analysis.
This server has prompt page and favicon image handling capability.
 Access this server from Chrome using : http://localhost:8080/

- **bin/middleware\_sample\_1.dart** : Sample middleware code showing how to hand modified request to the innerHandler.
 Access this server from Chrome using : http://localhost:8080/test

- **bin/middleware\_sample\_2.dart** : Sample middleware code that returns response directly.
Opening with 'http://localhost:8080/middleware' will cause direct return.
- **bin/middleware\_sample\_3.dart** : Sample middleware code showing how to modify the response from the innerHandler.
Call this server like 'http://localhost:8080/123'.

このサンプルは[「解説Dart 2プログラミング言語」](https://www.cresc.co.jp/tech/java/Google_Dart2/introduction/main_page.html)の 添付資料です。詳細は「ミドルウエア・フレームワーク (shelf)」の章をご覧ください。

These samples are attachments to the [Dart 2 Language Guide](https://www.cresc.co.jp/tech/java/Google_Dart2/introduction/main_page.html) written in Japanese.

### Installing ###

1. Download this repository, uncompress and rename the folder to **shelf\_test**.
2. From IDE, File > Open Folder and select this  **shelf\_test** folder.

### Try it ###

1. Run one of above servers.
2. Access the server from your browser following to instructions.
3. Tested on Windows.


### License ###
These samples are licensed under [MIT License](mit-license.php).
