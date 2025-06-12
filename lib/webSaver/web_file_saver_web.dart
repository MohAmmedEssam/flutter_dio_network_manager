import 'dart:typed_data';
import 'dart:html' as html;
import 'web_file_saver_interface.dart';

class WebFileSaverImpl implements WebFileSaver {
  @override
  Future<String> save(Uint8List bytes, String filename) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return url;
  }
}
