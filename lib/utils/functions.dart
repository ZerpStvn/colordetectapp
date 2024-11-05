import 'package:url_launcher/url_launcher.dart';

Future<void> openColorInspirationSearch(String colorName) async {
  final query = Uri.encodeComponent('$colorName design inspiration');
  final url = 'https://www.google.com/search?tbm=isch&q=$query';
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
