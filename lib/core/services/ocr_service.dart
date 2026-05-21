import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> scanReceipt(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  double extractAmount(String text) {
    final regex = RegExp(
      r'Rp[\s]*([0-9,.]+)|([0-9,.]+)[\s]*Rp|TOTAL[\s]*:[\s]*([0-9,.]+)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);

    if (match != null) {
      final amountStr =
          match.group(0)?.replaceAll(RegExp(r'[^0-9,]'), '') ?? '0';

      return double.tryParse(
            amountStr.replaceAll(',', '.'),
          ) ??
          0;
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
    _textRecognizer.close();
  }
}