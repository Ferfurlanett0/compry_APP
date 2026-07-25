import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('lib');
  int fixedCount = 0;
  final regex = RegExp(r'[\xC0-\xFD][\x80-\xBF]+');
  
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync(encoding: utf8);
      if (regex.hasMatch(content)) {
        final newContent = content.replaceAllMapped(regex, (match) {
          final str = match.group(0)!;
          try {
            final bytes = latin1.encode(str);
            return utf8.decode(bytes, allowMalformed: false);
          } catch (e) {
            return str;
          }
        });
        if (content != newContent) {
          file.writeAsStringSync(newContent, encoding: utf8);
          fixedCount++;
          print('Fixed ${file.path}');
        }
      }
    }
  }
  print('Fixed $fixedCount files');
}
