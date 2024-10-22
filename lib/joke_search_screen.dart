import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'sign_in_screen.dart';
import 'profile_screen.dart';

class JokeSearchScreen extends StatefulWidget {
  @override
  _JokeSearchScreenState createState() => _JokeSearchScreenState();
}

class _JokeSearchScreenState extends State<JokeSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> fetchJokes(String query) async {
    // Replace this with your actual API call logic
    print("Fetching jokes for query: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke Search'),
        backgroundColor: Colors.blue, // Ensure a consistent background color
        actions: [
          FirebaseAuth.instance.currentUser == null
              ? TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            child: Text(
              'Login / Sign Up',
              style: TextStyle(
                color: Colors.white, // Text color for visibility
                fontSize: 16, // Slightly larger font size
                fontWeight: FontWeight.bold, // Bold text for emphasis
              ),
            ),
          )
              : Row(
            children: [
              TextButton(
                onPressed: () async {
                  await _authService.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged out successfully')),
                  );
                  setState(() {}); // Refresh to show Login/Sign Up button
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white, // Text color for visibility
                    fontSize: 16, // Slightly larger font size
                    fontWeight: FontWeight.bold, // Bold text for emphasis
                  ),
                ),
              ),
              SizedBox(width: 8), // Add spacing between buttons
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 18, // Increase the size for better visibility
                  backgroundColor: Colors.white, // White background for contrast
                  child: Text(
                    _authService.getUserInitials(),
                    style: TextStyle(
                      color: Colors.blue, // Blue text for contrast
                      fontSize: 16, // Slightly larger font size
                      fontWeight: FontWeight.bold, // Bold text for emphasis
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12), // Add spacing between the profile icon and the edge
            ],
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
              child: Text('Get Jokes'),
            ),
          ],
        ),
      ),
    );
  }
}
