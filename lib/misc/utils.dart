import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:dart_image/dart_image.dart' as dimg;
import 'dart:math' as math;


class _ImageCompressionMessage {
  SendPort sendPort;
  File file;
}

class ImageUtil {
  static const int MAX = 1920;

  static List<int> compressImage(File file)  {
    return __compressImage(file);
  }

  static Future _compressImage(_ImageCompressionMessage message) async {
    message.sendPort.send(__compressImage(message.file));
  }

  static List<int> __compressImage(File file){
    print("Compressing image $file");
    print("Decoding image...");
    img.Image image = img.decodeImage(file.readAsBytesSync());
    if (image.width > ImageUtil.MAX || image.height > ImageUtil.MAX) {
      print("Resizing...");
      image = img.copyResize(image, targetWidth(image));
      print("Resized to ${image.width}x${image.height}");
    }

    print("Encoding...");
    List<int> compressed = img.encodeJpg(image, quality: 50);
    print("Returning...");
    return compressed;
  }

  static Future _dCompressImage(_ImageCompressionMessage message) async {
    print("Compressing image ${message.file}");
    print("Reading file...");
    message.file.openSync();
    List<int> data = message.file.readAsBytesSync();

    print("Decoding image...");
    dimg.Decoder decoder = new dimg.JpegDecoder();
    dimg.Image image = decoder.decode(data);
    if (image.height > ImageUtil.MAX || image.width > ImageUtil.MAX) {
      print("Resizing image...");
      double max = math.max(image.height, image.width).toDouble();
      double factor = ImageUtil.MAX / max;
      image = image.resized((image.width.toDouble() * factor).round(),
          (image.height.toDouble() * factor).round());

      print("New image format: ${image.width}x${image.height}");
    }

    print("Encoding image... ${image.width}x${image.height}");
    dimg.Encoder encoder = new dimg.JpegEncoder(40);
    List<int> compressed = encoder.encode(image);

    print("Returning image");
    message.sendPort.send(compressed);
  }

  static int targetWidth(img.Image image) {
    if (image.width > image.height) {
      if (image.width > ImageUtil.MAX) {
        return ImageUtil.MAX;
      } else {
        return image.width;
      }
    }
    else {
      if (image.height > ImageUtil.MAX) {
        double shrinkage = ImageUtil.MAX.toDouble() / image.height.toDouble();
        return (image.width.toDouble() * shrinkage).floor();
      } else {
        return image.width;
      }
    }
  }
}