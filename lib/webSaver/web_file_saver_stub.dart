import 'dart:typed_data';
import 'web_file_saver_interface.dart';

class WebFileSaverImpl implements WebFileSaver {
  @override
  Future<String> save(Uint8List bytes, String filename) async {
    throw UnsupportedError('Web file saving is only supported on web.');
  }
}
