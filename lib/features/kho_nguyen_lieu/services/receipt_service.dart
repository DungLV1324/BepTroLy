import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptService {
  final ImagePicker _picker = ImagePicker();

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<List<String>> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      List<String> rawItems = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();

          if (text.length < 3) continue;

          String lower = text.toLowerCase();
          if (lower.contains("total") ||
              lower.contains("subtotal") ||
              lower.contains("tax") ||
              lower.contains("cash") ||
              lower.contains("change") ||
              lower.contains("thank you") ||
              lower.contains("date:") ||
              lower.contains("tel:") ||
              lower.contains("receipt")) {
            continue;
          }

          if (RegExp(r'^[\d\.,\$\₫\s]+$').hasMatch(text)) {
            continue;
          }

          text = text.replaceAll(RegExp(r'[\d\.,\s]+$'), '').trim();

          if (text.isNotEmpty) {
            rawItems.add(text);
          }
        }
      }
      return rawItems;
    } catch (e) {
      print("Lỗi OCR: $e");
      return [];
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}