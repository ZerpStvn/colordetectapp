import 'package:colordetect/pages/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _image;
  Map<String, double> _detectedColors = {};
  bool _isLoading = false; // Variable to track the loading state
  final ImagePicker _picker = ImagePicker();

  // Mapping color names to Flutter color codes
  final Map<String, Color> colorMap = {
    "red": Colors.red,
    "dark red": const Color(0xFF8B0000), // Dark Red
    "green": Colors.green,
    "blue": Colors.blue,
    "yellow": Colors.yellow,
    "cyan": Colors.cyan,
    "magenta": Colors.purple, // Close to magenta
    "purple": Colors.purple,
    "orange": Colors.orange,
    "pink": Colors.pink,
    "brown": const Color(0xFF8B4513), // Brown
    "gray": Colors.grey,
    "black": Colors.black,
    "white": Colors.white,
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: maincolor,
            title: const Text(
              'Color Detection',
              style: TextStyle(color: Colors.white),
            )),
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
              // _isLoading
              //     ? const CircularProgressIndicator()
              //     : ElevatedButton(
              //         onPressed: _isLoading
              //             ? null
              //             : _pickImage, // Disable button while loading
              //         child: const Text('Select Image'),
              //       ),

              const SizedBox(height: 20),
              _detectedColors.isNotEmpty && !_isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        shrinkWrap:
                            true, // Allows GridView to take only the needed space
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents GridView from scrolling independently
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 4,
                        ),
                        itemCount: _detectedColors.length,
                        itemBuilder: (context, index) {
                          final colorEntry =
                              _detectedColors.entries.elementAt(index);
                          final colorName = colorEntry.key;
                          final colorPercentage = colorEntry.value;
                          final displayColor =
                              colorMap[colorName] ?? Colors.black;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: displayColor,
                                      border: Border.all(
                                          width: 1, color: Colors.black)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$colorName: ${colorPercentage.toStringAsFixed(2)}%',
                                  style: const TextStyle(fontSize: 18),
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
}
