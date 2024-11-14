import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'drawer.dart';

void main() {
  runApp(MemeApp());
}

class MemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic based on the index if needed
    });
  }

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
      drawer: Appdrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Meme Generation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white), // Drawer icon color
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
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
              child: Text('Generate Memes'),
            ),
            SizedBox(height: 16),
            if (_question != null)
              Text(
                'Entered Text: $_question',
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
