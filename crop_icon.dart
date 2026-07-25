import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('web/icons/icone_compry.png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) return;

  int minX = image.width;
  int minY = image.height;
  int maxX = 0;
  int maxY = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixelSafe(x, y);
      if (pixel.a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  print('Cropping from $minX, $minY to $maxX, $maxY');
  final cropped = img.copyCrop(image, x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);
  File('assets/icons/icone_compry_cropped.png').writeAsBytesSync(img.encodePng(cropped));
  print('Saved cropped image.');
}
