import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math';

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({super.key});

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  Color detectedColor = Colors.transparent;
  bool isStreaming = false;
  String hexColor = "";
  String rgbColor = "";
  String colorName = "";

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      await controller!.initialize();
      if (!mounted) return;
      setState(() {});
      startImageStream();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void startImageStream() {
    if (isStreaming || controller == null || !controller!.value.isInitialized) {
      return;
    }
    isStreaming = true;
    controller!.startImageStream((CameraImage image) {
      detectColorFromImage(image);
    });
  }

  void detectColorFromImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    const int boxSize = 100;
    final int centerX = width ~/ 2;
    final int centerY = height ~/ 2;
    final int startX = centerX - (boxSize ~/ 2);
    final int startY = centerY - (boxSize ~/ 2);

    int totalR = 0;
    int totalG = 0;
    int totalB = 0;
    int count = 0;

    for (int x = startX; x < startX + boxSize; x++) {
      for (int y = startY; y < startY + boxSize; y++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final int uvIndex =
              image.planes[1].bytesPerRow * (y ~/ 2) + (x ~/ 2) * 2;
          final int u = image.planes[1].bytes[uvIndex] - 128;
          final int v = image.planes[2].bytes[uvIndex] - 128;

          final int yIndex = image.planes[0].bytesPerRow * y + x;
          final int yValue = image.planes[0].bytes[yIndex];

          int r = (yValue + (1.370705 * v)).round();
          int g = (yValue - (0.337633 * u) - (0.698001 * v)).round();
          int b = (yValue + (1.732446 * u)).round();

          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          totalR += r;
          totalG += g;
          totalB += b;
          count++;
        }
      }
    }

    int avgR = (totalR ~/ count).clamp(0, 255);
    int avgG = (totalG ~/ count).clamp(0, 255);
    int avgB = (totalB ~/ count).clamp(0, 255);

    setState(() {
      detectedColor = Color.fromARGB(255, avgR, avgG, avgB);
      hexColor =
          '#${detectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      rgbColor =
          'RGB(${detectedColor.red}, ${detectedColor.green}, ${detectedColor.blue})';
      colorName = getColorNameFromRGB(avgR, avgG, avgB);
    });
  }

  // Helper function to map RGB to a human-readable color name
  String getColorNameFromRGB(int r, int g, int b) {
    Map<String, List<int>> colorMap = {
      "black": [0, 0, 0],
      "white": [255, 255, 255],
      "red": [255, 0, 0],
      "green": [0, 255, 0],
      "blue": [0, 0, 255],
      "yellow": [255, 255, 0],
      "cyan": [0, 255, 255],
      "magenta": [255, 0, 255],
      "gray": [128, 128, 128],
      "orange": [255, 165, 0],
      "purple": [128, 0, 128],
      "pink": [255, 192, 203],
      "brown": [165, 42, 42],
    };

    String closestColor = "";
    double minDistance = double.infinity;

    colorMap.forEach((name, rgbValues) {
      double distance = sqrt(pow(r - rgbValues[0], 2) +
          pow(g - rgbValues[1], 2) +
          pow(b - rgbValues[2], 2));
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = name;
      }
    });

    return closestColor;
  }

  @override
  void dispose() {
    if (controller != null && isStreaming) {
      controller!.stopImageStream();
      isStreaming = false;
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          "Color Detection",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(controller!),
          ),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 50,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: detectedColor,
                  border: Border.all(width: 1, color: Colors.black)),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hex: $hexColor',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      backgroundColor: Colors.black),
                ),
                Text(
                  'RGB: $rgbColor',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      backgroundColor: Colors.black),
                ),
                Text(
                  'Color Name: $colorName',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      backgroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
