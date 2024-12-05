import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageToBase64 extends StatefulWidget {
  @override
  _ImageToBase64State createState() => _ImageToBase64State();
}

class _ImageToBase64State extends State<ImageToBase64> {
  final picker = ImagePicker();
  String? base64Image;

  // Pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _convertImageToBase64(pickedFile.path);
    }
  }

  // Convert image to Base64
  Future<void> _convertImageToBase64(String imagePath) async {
    try {
      final byteData = await pickedFile.readAsBytes();
      String base64String = base64Encode(byteData);

      setState(() {
        base64Image = base64String;
      });

      // Save the base64 string to Firebase Realtime Database
      _storeImageInFirebase(base64String);
    } catch (e) {
      print("Error converting image to Base64: $e");
    }
  }

  // Store the Base64 string in Firebase Realtime Database
  Future<void> _storeImageInFirebase(String base64String) async {
    final databaseReference = FirebaseDatabase.instance.reference();
    final userImageRef = databaseReference.child('images').push();

    await userImageRef.set({
      'image_data': base64String, // Store the Base64 string here
    });

    print("Image stored in Firebase");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to Base64 Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            if (base64Image != null) ...[
              Text('Base64 String:'),
              SizedBox(height: 10),
              Text(base64Image!, maxLines: 5, overflow: TextOverflow.ellipsis),
            ]
          ],
        ),
      ),
    );
  }
}
