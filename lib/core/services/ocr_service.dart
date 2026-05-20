// lib/core/services/ocr_service.dart
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextDetector _textDetector = GoogleMlKit.vision.textDetector();

  Future<String> scanReceipt(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognisedText recognisedText =
          await _textDetector.processImage(inputImage);

      return recognisedText.text;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  double extractAmount(String text) {
    final regex = RegExp(
      r'Rp[\s]*([0-9,.]+)|([0-9,.]+)[\s]*Rp|TOTAL[\s]*:[\s]*([0-9,.]+)',
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final amountStr =
          match.group(0)?.replaceAll(RegExp(r'[^0-9,]'), '') ?? '0';
      return double.parse(amountStr.replaceAll(',', '.'));
    }
    return 0;
  }

  DateTime extractDate(String text) {
    final regex = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final match = regex.firstMatch(text);
    if (match != null) {
      return DateTime.now();
    }
    return DateTime.now();
  }

  void dispose() {
    _textDetector.close();
  }
}
