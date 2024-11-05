// import 'package:colordetect/model/colorharmony.dart';
// import 'package:flutter/material.dart';

// void showColorHarmoniesModal(
//     Color color, dynamic _buildHarmonyRow, BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Color Harmonies',
//                   style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 10),
//               _buildHarmonyRow(
//                   'Complementary', ColorHarmony.getComplementary(color)),
//               _buildHarmonyRow('Analogous', ColorHarmony.getAnalogous(color)),
//               _buildHarmonyRow('Triadic', ColorHarmony.getTriadic(color)),
//               _buildHarmonyRow(
//                   'Monochromatic', ColorHarmony.getMonochromatic(color)),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
