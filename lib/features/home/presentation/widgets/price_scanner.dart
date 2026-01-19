import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PriceScannerPage extends StatefulWidget {
  const PriceScannerPage({super.key});

  @override
  State<PriceScannerPage> createState() => _PriceScannerPageState();
}

class _PriceScannerPageState extends State<PriceScannerPage> {
  late CameraController _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();

  bool _isInitialized = false;
  bool _isProcessing = false;
  String price = '';

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  String buildPricePrompt(String ocrText) {
    return """
          You are given raw OCR text extracted from a product price tag.
          
          Task:
          - Extract the FINAL product price ONLY.
          - Ignore quantities, weights (g, kg, ml), barcodes, dates, discounts, and store codes.
          - Prefer values that look like a price
          - If multiple prices exist, return the MOST LIKELY final price.
          
          Return format (STRICT):
          {
            "price": number
          }
          
          Rules:
          - "price" MUST be a number (not a string).
          - Do NOT include currency symbols.
          - Do NOT include any additional text.
          - If no valid price is found, return:
            { "price": null }
          
          OCR TEXT:
          ${ocrText}
          """;
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _scanPrice() async {
    try {
      setState(() => _isProcessing = true);

      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      final ocrText = recognizedText.text;

      final prompt = buildPricePrompt(ocrText);

      final response = await model.generateContent([
        Content.text(prompt),
      ]);


      if (response.text == null) {
        if (!mounted) return;
        Navigator.pop(context, null);
        return;
      }

      final decoded = jsonDecode(response.text!);
      final double? price =
      (decoded['price'] as num?)?.toDouble();
      print('R1 ${price.toString()}');

    if (!mounted) return;
      Navigator.pop(context, price);
    } catch (e) {
      debugPrint("R1 Scan error: $e");
      if (mounted) {
        Navigator.pop(context, null);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Scan Price")),
        body: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _scanPrice,
                      icon: const Icon(Icons.camera_alt),
                      label: _isProcessing
                          ? const Text("Scanning...")
                          : const Text("SCAN PRICE TAG"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
