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

    final int boxSize = (min(width, height) * 0.05)
        .toInt(); // Smaller box size for more accuracy
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

          int r = (yValue + 1.402 * v).round();
          int g = (yValue - 0.344136 * u - 0.714136 * v).round();
          int b = (yValue + 1.772 * u).round();

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

    if (count > 0) {
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
  }

  List<double> rgbToLab(int r, int g, int b) {
    double red = r / 255.0;
    double green = g / 255.0;
    double blue = b / 255.0;

    red =
        red > 0.04045 ? pow((red + 0.055) / 1.055, 2.4) as double : red / 12.92;
    green = green > 0.04045
        ? pow((green + 0.055) / 1.055, 2.4) as double
        : green / 12.92;
    blue = blue > 0.04045
        ? pow((blue + 0.055) / 1.055, 2.4) as double
        : blue / 12.92;

    double x = (red * 0.4124 + green * 0.3576 + blue * 0.1805) / 0.95047;
    double y = (red * 0.2126 + green * 0.7152 + blue * 0.0722) / 1.0;
    double z = (red * 0.0193 + green * 0.1192 + blue * 0.9505) / 1.08883;

    x = x > 0.008856
        ? pow(x, 1.0 / 3.0) as double
        : (7.787 * x) + (16.0 / 116.0);
    y = y > 0.008856
        ? pow(y, 1.0 / 3.0) as double
        : (7.787 * y) + (16.0 / 116.0);
    z = z > 0.008856
        ? pow(z, 1.0 / 3.0) as double
        : (7.787 * z) + (16.0 / 116.0);

    double l = (116.0 * y) - 16.0;
    double a = 500.0 * (x - y);
    double labB = 200.0 * (y - z);

    return [l, a, labB];
  }

  String getColorNameFromRGB(int r, int g, int b) {
    Map<String, List<int>> colorMap = {
      "black": [0, 0, 0],
      "white": [255, 255, 255],
      "red": [255, 0, 0],
      "dark red": [139, 0, 0],
      "light red": [255, 128, 128],
      "green": [0, 255, 0],
      "dark green": [0, 100, 0],
      "light green": [144, 238, 144],
      "blue": [0, 0, 255],
      "dark blue": [0, 0, 139],
      "light blue": [173, 216, 230],
      "yellow": [255, 255, 0],
      "gold": [255, 215, 0],
      "orange": [255, 165, 0],
      "brown": [139, 69, 19],
      "saddle brown": [139, 69, 19],
      "chocolate": [210, 105, 30],
      "sienna": [160, 82, 45],
      "light brown": [210, 180, 140],
      "pink": [255, 192, 203],
      "hot pink": [255, 105, 180],
      "purple": [128, 0, 128],
      "lavender": [230, 230, 250],
      "magenta": [255, 0, 255],
      "cyan": [0, 255, 255],
      "teal": [0, 128, 128],
      "coral": [255, 127, 80],
      "peach": [255, 218, 185],
      "khaki": [240, 230, 140],
      "beige": [245, 245, 220],
      "olive": [128, 128, 0],
      "gray": [128, 128, 128],
      "light gray": [211, 211, 211],
      "dark gray": [169, 169, 169],
      "turquoise": [64, 224, 208],
      "navy": [0, 0, 128]
    };

    final targetLab = rgbToLab(r, g, b);
    String closestColor = "";
    double minDistance = double.infinity;

    colorMap.forEach((name, rgbValues) {
      final labValues = rgbToLab(rgbValues[0], rgbValues[1], rgbValues[2]);
      double distance = sqrt(pow(targetLab[0] - labValues[0], 2) +
          pow(targetLab[1] - labValues[1], 2) +
          pow(targetLab[2] - labValues[2], 2));

      if (distance < minDistance) {
        minDistance = distance;
        closestColor = name;
      }
    });

    // Check saturation and red level to distinguish brown from gray
    double saturation = calculateSaturation(r, g, b);
    if (closestColor == "gray" && saturation > 0.1 && r > g && r > b) {
      closestColor = "brown"; // Adjust based on your testing
    }

    return closestColor;
  }

// Function to calculate saturation of the color
  double calculateSaturation(int r, int g, int b) {
    double max = [r, g, b].reduce((a, b) => a > b ? a : b) / 255.0;
    double min = [r, g, b].reduce((a, b) => a < b ? a : b) / 255.0;
    return (max - min) / max;
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
              width: 25, // Adjusted to match the smaller box size in detection
              height: 25, // Adjusted to match the smaller box size in detection
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
