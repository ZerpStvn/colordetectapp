import 'package:colordetect/model/colorblindness.dart';
import 'package:colordetect/model/colorharmony.dart';
import 'package:colordetect/pages/camera.dart';
import 'package:colordetect/pages/theme.dart';
import 'package:colordetect/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool permissionsGranted = false;
  File? _image;
  Map<String, double> _detectedColors = {};
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final Map<String, Color> colorMap = {
    "red": Colors.red,
    "dark red": const Color(0xFF8B0000),
    "light red": const Color(0xFFFFA07A),
    "green": Colors.green,
    "dark green": const Color(0xFF006400),
    "light green": const Color(0xFF90EE90),
    "blue": Colors.blue,
    "dark blue": const Color(0xFF00008B),
    "light blue": const Color(0xFFADD8E6),
    "yellow": Colors.yellow,
    "dark yellow": const Color(0xFFDAA520),
    "light yellow": const Color(0xFFFFFFE0),
    "cyan": Colors.cyan,
    "dark cyan": const Color(0xFF008B8B),
    "magenta": Colors.purple,
    "purple": Colors.purple,
    "dark purple": const Color(0xFF4B0082),
    "light purple": const Color(0xFFE6E6FA),
    "orange": Colors.orange,
    "light orange": const Color(0xFFFFDAB9),
    "pink": Colors.pink,
    "brown": const Color(0xFF8B4513),
    "gray": Colors.grey,
    "dark gray": const Color(0xFF505050),
    "light gray": const Color(0xFFD3D3D3),
    "black": Colors.black,
    "white": Colors.white,
    "beige": const Color(0xFFF5F5DC),
    "peach": const Color(0xFFFFE5B4),
  };

  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      setState(() {
        permissionsGranted = true;
      });
    } else if (cameraStatus.isPermanentlyDenied ||
        storageStatus.isPermanentlyDenied) {
      openAppSettings();
    } else {
      debugPrint("Permissions not granted.");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
        });
        await _uploadImage(_image!);
      }
    } catch (error) {
      debugPrint("$error");
    }
  }

  Future<void> _pickcamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    // final uri = Uri.parse('http://10.0.2.2:5000/upload');
    final uri = Uri.parse('https://colorflask.onrender.com/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(responseBody.body);
      setState(() {
        _detectedColors = {for (var e in data['colors']) e[0]: e[1]};
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error: ${responseBody.statusCode}');
    }
  }

  // Function to display color harmonies in a modal
  void _showColorHarmoniesModal(Color color) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Color Harmonies',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                _buildHarmonyRow(
                    'Complementary', ColorHarmony.getComplementary(color)),
                _buildHarmonyRow('Analogous', ColorHarmony.getAnalogous(color)),
                _buildHarmonyRow('Triadic', ColorHarmony.getTriadic(color)),
                _buildHarmonyRow(
                    'Monochromatic', ColorHarmony.getMonochromatic(color)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHarmonyRow(String title, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: colors.map((color) {
              return Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(width: 1, color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: maincolor,
          title: const Text(
            'Color Detection',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                modalshow();
              },
              icon: const Icon(
                Icons.camera_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        decoration: const BoxDecoration(color: reguralcolor),
                        child: const Center(
                          child: Text("Select Image"),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              _isLoading
                  ? const LinearProgressIndicator(
                      color: secondarycolor,
                    )
                  : Container(),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       _detectedColors.isNotEmpty && !_isLoading
              //           ? Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: ElevatedButton(
              //                   style: ElevatedButton.styleFrom(
              //                       backgroundColor: maincolor,
              //                       shape: RoundedRectangleBorder(
              //                           borderRadius:
              //                               BorderRadius.circular(4))),
              //                   onPressed: () {
              //                     _showColorBlindnessModal();
              //                   },
              //                   child: Text(
              //                     "Color Blind Simulation",
              //                     style: TextStyle(color: Colors.white),
              //                   )),
              //             )
              //           : Container(),
              //     ],
              //   ),
              // ),
              _detectedColors.isNotEmpty && !_isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Color Detected",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              _detectedColors.isNotEmpty && !_isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 1,
                        ),
                        itemCount: _detectedColors.length,
                        itemBuilder: (context, index) {
                          final colorEntry =
                              _detectedColors.entries.elementAt(index);
                          final colorName = colorEntry.key;
                          final displayColor =
                              colorMap[colorName] ?? Colors.black;

                          return GestureDetector(
                            onLongPress: () {
                              _showColorHarmoniesModal(displayColor);
                            },
                            onTap: () {
                              openColorInspirationSearch(colorName);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: displayColor,
                                    border: Border.all(
                                        width: 1, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  colorName[0].toUpperCase() +
                                      colorName.substring(1),
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : !_isLoading
                      ? const Text('No colors detected.')
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void showAlertInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Text(
              "The color detection results may not be accurate. This is because the accuracy of detection depends on various factors, such as lighting conditions, camera quality, and the presence of reflective surfaces or obstructions in the environment."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraDetectionPage()));
                debugPrint("hello");
              },
              child: Text("okay"),
            ),
          ],
        );
      },
    );
  }

  void modalshow() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 230,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_outlined),
                    onTap: () {
                      _pickcamera();
                      Navigator.pop(context);
                    },
                    title: const Text("Take a Photo"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_chat_outlined),
                    onTap: () {
                      showAlertInfo();
                    },
                    title: const Text("Real Time Color Detection"),
                  ),
                  _image != null
                      ? ListTile(
                          leading: const Icon(Icons.image_outlined),
                          onTap: () {
                            _pickImage();
                            Navigator.pop(context);
                          },
                          title: const Text("Select Another Image"),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorBlindnessModal() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(),
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Color Blindness Simulations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildColorBlindnessSimulationRow("Protanopia", applyProtanopia),
              _buildColorBlindnessSimulationRow(
                  "Deuteranopia", applyDeuteranopia),
              _buildColorBlindnessSimulationRow("Tritanopia", applyTritanopia),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorBlindnessSimulationRow(
      String type, Color Function(Color) simulator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(11.0),
            child: Text(type,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: _detectedColors.keys.map((colorName) {
                  final originalColor = colorMap[colorName] ?? Colors.black;
                  final simulatedColor = simulator(originalColor);
                  return Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          color: simulatedColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          colorName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
