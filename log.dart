import 'dart:io';

void log(String message) {
  File('app_log.txt').writeAsStringSync('$message\n', mode: FileMode.append);
}

// Gunakan seperti ini
// log('Ini adalah pesan debug');