part of 'price_scanner_bloc.dart';

abstract class PriceScannerEvent {}

class InitializeCameraEvent extends PriceScannerEvent {}

class ScanPriceEvent extends PriceScannerEvent {}