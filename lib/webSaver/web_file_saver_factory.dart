import 'web_file_saver_interface.dart';
import 'web_file_saver_stub.dart'
    if (dart.library.html) 'web_file_saver_web.dart'
    as saver;

final WebFileSaver webFileSaver = saver.WebFileSaverImpl();
