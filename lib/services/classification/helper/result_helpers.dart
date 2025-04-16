import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

img.Image preprocessImage(File imageFile) {
  final original = img.decodeImage(imageFile.readAsBytesSync())!;
  return img.copyResize(original, width: 224, height: 224);
}

List<List<List<List<double>>>> imageToInputTensor(img.Image image) {
  return [
    List.generate(224, (y) {
      return List.generate(224, (x) {
        final pixel = image.getPixel(x, y);
        return [
          img.getRed(pixel) / 255.0,
          img.getGreen(pixel) / 255.0,
          img.getBlue(pixel) / 255.0,
        ];
      });
    })
  ];
}

Future<File> resizeAndSaveImage(img.Image image, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$filename';
  return File(path)..writeAsBytesSync(img.encodeJpg(image));
}
