import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 108, height: 108);
  File('assets/icons/empty.png').writeAsBytesSync(img.encodePng(image));
}
