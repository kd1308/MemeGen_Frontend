import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MemeApp());
}

class MemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemeGeneratorPage(),
    );
  }
}

class MemeGeneratorPage extends StatefulWidget {
  @override
  _MemeGeneratorPageState createState() => _MemeGeneratorPageState();
}

class _MemeGeneratorPageState extends State<MemeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _memes = [];

  Future<void> _generateMemes(String topic) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/generate_memes/?input_text=$topic'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _memes = data;
      });
    } else {
      throw Exception('Failed to load memes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meme Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a topic',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _generateMemes(_controller.text);
                }
              },
              child: Text('Generate Memes'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _memes.length,
                itemBuilder: (context, index) {
                  final meme = _memes[index];
                  return Card(
                    child: Column(
                      children: [
                        Image.network(meme['template']),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(meme['keywords']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
