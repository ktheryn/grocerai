import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/price_scanner_bloc/price_scanner_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/price_scanner_bloc/price_scanner_state.dart';

class PriceScannerPage extends StatelessWidget {
  const PriceScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PriceScannerBloc()..add(InitializeCameraEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Scan Price")),
        body: BlocConsumer<PriceScannerBloc, PriceScannerState>(
          listener: (context, state) {
            if (state is PriceScannerSuccess) {
              Navigator.pop(context, state.price);
            }
            if (state is PriceScannerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is PriceScannerInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            CameraController? controller;
            bool isProcessing = false;

            if (state is PriceScannerCameraReady) {
              controller = state.controller;
            } else if (state is PriceScannerProcessing) {
              controller = state.controller;
              isProcessing = true;
            }

            if (controller == null) return const SizedBox.shrink();

            return Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => context.read<PriceScannerBloc>().add(ScanPriceEvent()),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(isProcessing ? "Scanning..." : "SCAN PRICE TAG"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}