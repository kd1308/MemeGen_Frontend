import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DisplayImage extends StatelessWidget {
  final String imageUrl;

  DisplayImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Image')),
      body: Center(
        child: FutureBuilder(
          future: FirebaseDatabase.instance
              .reference()
              .child('images')
              .child(imageUrl)
              .once(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasData) {
              final base64String = snapshot.data['image_data'];
              Uint8List bytes = base64Decode(base64String);

              return Image.memory(bytes);
            } else {
              return Text("No image found");
            }
          },
        ),
      ),
    );
  }
}
