import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class FullImagePage extends StatelessWidget {
  final String imgUrl;

  const FullImagePage({super.key, required this.imgUrl});

  Future<void> downloadImage(String imageUrl) async {
    try {
      // Get the directory to save the image in the app's local storage
      Directory appDocDir;

      // For Android, save to external storage (Downloads folder)
      if (Platform.isAndroid) {
        appDocDir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        // For iOS, save to the app's Documents directory
        appDocDir = await getApplicationDocumentsDirectory();
      }

      String formattedDate =
          DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());

      // Create the path using the formatted date
      String savePath =
          '${appDocDir.path}/$formattedDate.jpg'; // Path to save image// Path to save image

      // Make a network request to get the image
      Dio dio = Dio();

      // Download the image and save it locally
      await dio.download(imageUrl, savePath);

      print('Image downloaded successfully to $savePath');
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFEBF3FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_emotions, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Meme Generation',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Call the downloadImage function when the button is pressed
              downloadImage(imgUrl);
            },
            icon: const Icon(Icons.download),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imgUrl,
            ),
          ),
        ),
      ),
    ));
  }
}
