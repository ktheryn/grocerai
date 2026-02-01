import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:grocerai/features/home/data/ai_grocery_repository.dart';
import 'package:grocerai/locator.dart';
import 'package:grocerai/features/home/presentation/bloc/price_scanner_bloc/price_scanner_state.dart';
part 'price_scanner_event.dart';

class PriceScannerBloc extends Bloc<PriceScannerEvent, PriceScannerState> {
  final AIGeneratedGroceryRepository _repository = getIt<AIGeneratedGroceryRepository>();

  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();

  PriceScannerBloc() : super(PriceScannerInitial()) {
    on<InitializeCameraEvent>(_onInitialize);
    on<ScanPriceEvent>(_onScanPrice);
  }

  Future<void> _onInitialize(InitializeCameraEvent event, Emitter<PriceScannerState> emit) async {
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

      await _cameraController!.initialize();
      emit(PriceScannerCameraReady(_cameraController!));
    } catch (e) {
      emit(PriceScannerError("Camera initialization failed."));
    }
  }

  Future<void> _onScanPrice(ScanPriceEvent event, Emitter<PriceScannerState> emit) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final currentController = _cameraController!;

    try {
      emit(PriceScannerProcessing(currentController));

      final image = await currentController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      final double price = await _repository.fetchPriceFromOcrText(recognizedText.text);

      if (price > 0) {
        emit(PriceScannerSuccess(price));
      } else {
        emit(PriceScannerError("Could not find a valid price."));
        emit(PriceScannerCameraReady(currentController));
      }
    } catch (e) {
      emit(PriceScannerError("Scanning failed. Please try again."));
      emit(PriceScannerCameraReady(currentController));
    }
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    _textRecognizer.close();
    return super.close();
  }
}