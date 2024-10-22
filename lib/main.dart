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
      home: JokeSearchScreen(),
    );
  }
}

class JokeSearchScreen extends StatefulWidget {
  @override
  _JokeSearchScreenState createState() => _JokeSearchScreenState();
}

class _JokeSearchScreenState extends State<JokeSearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> _memes = []; // Change to List<String> for clarity
  String? _question; // To store the question from the response

  Future<void> fetchJokes(String query) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Convert dynamically typed list to List<String>
        _memes = List<String>.from(
            data['suggestions'].map((item) => item.toString()));
        _question = data['question']; // Store the question from the response
      });
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                fetchJokes(_controller.text);
              },
              child: Text('Get Jokes'),
            ),
            SizedBox(height: 16),
            // Display the question received from the backend
            if (_question != null)
              Text(
                'Question: $_question',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _memes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_memes[index]),
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
