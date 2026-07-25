import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('web/icons/icone_compry.png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image != null) {
    print('Size: ${image.width} x ${image.height}');
    final pixel = image.getPixelSafe(image.width ~/ 2, image.height ~/ 2);
    final topPixel = image.getPixelSafe(10, 10);
    print('Center: #' + pixel.r.toInt().toRadixString(16).padLeft(2, '0') + pixel.g.toInt().toRadixString(16).padLeft(2, '0') + pixel.b.toInt().toRadixString(16).padLeft(2, '0') + ' alpha: ' + pixel.a.toInt().toString());
    print('TopLeft: #' + topPixel.r.toInt().toRadixString(16).padLeft(2, '0') + topPixel.g.toInt().toRadixString(16).padLeft(2, '0') + topPixel.b.toInt().toRadixString(16).padLeft(2, '0') + ' alpha: ' + topPixel.a.toInt().toString());
  }
}
