import 'package:flutter/material.dart';

class MemeGrid extends StatelessWidget {
  final List<String> memeImages;
  final Function(String) onImageTap;

  MemeGrid({required this.memeImages, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: memeImages.length,
      itemBuilder: (context, index) {
        final imageUrl = 'http://10.0.2.2:8000${memeImages[index]}';
        return GestureDetector(
          onTap: () => onImageTap(imageUrl),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Text('Image not available')),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
