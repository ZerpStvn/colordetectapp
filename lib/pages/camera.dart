// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   final ImagePicker _picker = ImagePicker();
//   File? _image;

//   // Function to capture image using the camera
//   Future<void> _captureImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Take a Photo')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image == null ? Text('No image captured.') : Image.file(_image!),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _captureImage,
//               child: Text('Capture Image'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _image == null
//                   ? null
//                   : () {
//                       Navigator.pop(context,
//                           _image); // Return the captured image to the previous screen
//                     },
//               child: Text('Use This Photo'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
