import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('web/icons/icone_compry.png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image != null) {
    final boxPixel = image.getPixelSafe(1000, 1000);
    print('Box: #' + boxPixel.r.toInt().toRadixString(16).padLeft(2, '0') + boxPixel.g.toInt().toRadixString(16).padLeft(2, '0') + boxPixel.b.toInt().toRadixString(16).padLeft(2, '0') + ' alpha: ' + boxPixel.a.toInt().toString());
  }
}
