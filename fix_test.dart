import 'dart:convert';
import 'dart:io';

String fixCorrupted(String input) {
  final regex = RegExp(r'[\x80-\xFF]+');
  return input.replaceAllMapped(regex, (match) {
    final str = match.group(0)!;
    try {
      final bytes = latin1.encode(str);
      return utf8.decode(bytes, allowMalformed: false);
    } catch (e) {
      return str;
    }
  });
}

void main() {
  print(fixCorrupted('Configura√ß√µes, Usu√°rio, Hist√≥rico, ‚Äî ! ?? Á „ ı'));
}
