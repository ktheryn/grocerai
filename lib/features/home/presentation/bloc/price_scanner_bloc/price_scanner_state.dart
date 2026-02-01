import 'package:camera/camera.dart';

abstract class PriceScannerState {}

class PriceScannerInitial extends PriceScannerState {}

class PriceScannerCameraReady extends PriceScannerState {
  final CameraController controller;
  PriceScannerCameraReady(this.controller);
}

class PriceScannerProcessing extends PriceScannerState {
  final CameraController controller;
  PriceScannerProcessing(this.controller);
}

class PriceScannerSuccess extends PriceScannerState {
  final double price;
  PriceScannerSuccess(this.price);
}

class PriceScannerError extends PriceScannerState {
  final String message;
  PriceScannerError(this.message);
}