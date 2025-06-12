import 'dart:typed_data';

abstract class WebFileSaver {
  Future<String> save(Uint8List bytes, String filename);
}
