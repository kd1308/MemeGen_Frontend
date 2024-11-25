import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meme_app/auth_service.dart';
import 'package:meme_app/sign_in_screen.dart';
import 'dart:convert';
import 'drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
      home: MemeGenerationPage(),
    );
  }
}

class MemeGenerationPage extends StatefulWidget {
  @override
  _MemeGenerationPageState createState() => _MemeGenerationPageState();
}

class _MemeGenerationPageState extends State<MemeGenerationPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _controller = TextEditingController();
  String? _question;
  List<Map<String, dynamic>> _memes = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  // Check if user is logged in
  void checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Redirect to sign-in if not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      });
    }
  }

  // Handle Sign-Out
  Future<void> handleSignOut() async {
    await _authService.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Sign-Out Successful'),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Future<void> fetchMemes(String query) async {
    setState(() {
      _question = query;
      _memes = [];
      _isLoading = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['top_memes'] != null) {
          setState(() {
            _memes = List<Map<String, dynamic>>.from(data['top_memes']);
          });
        } else {
          setState(() {
            _memes = [];
          });
        }
      } else {
        print('Failed to fetch memes. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching memes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: handleSignOut,
            ),
        ],
      ),
      body: user == null
          ? Center(
              child: Text(
                'Please log in to view memes.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
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
                    onPressed: () => fetchMemes(_controller.text),
                    child: Text('Generate Memes'),
                  ),
                  SizedBox(height: 16),
                  if (_question != null)
                    Text(
                      'Entered Text: $_question',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 8),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _memes.length,
                            itemBuilder: (context, index) {
                              final meme = _memes[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Text: ${meme['text']}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Emotion: ${meme['emotion']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Image.network(
                                        'http://10.0.2.2:8000${meme['image']}',
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {}, // Define navigation logic if needed
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

//
// class JokeSearchScreen extends StatefulWidget {
//   @override
//   _JokeSearchScreenState createState() => _JokeSearchScreenState();
// }
//
// class _JokeSearchScreenState extends State<JokeSearchScreen> {
//   int _selectedIndex = 0;
//
//   void _onBottomNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // Add navigation logic based on the index if needed
//     });
//   }
//
//   TextEditingController _controller = TextEditingController();
//   List<String> _memes = []; // Change to List<String> for clarity
//   String? _question; // To store the question from the response
//   Map<String, dynamic>? apiResponse;
//
//   Future<void> fetchJokes(String query) async {
//     final response = await http.get(
//       Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
//     );
//
//     // if (response.statusCode == 200) {
//     //   final data = json.decode(response.body);
//     //   setState(() {
//     //     // Convert dynamically typed list to List<String>
//     //     _memes = List<String>.from(
//     //         data['suggestions'].map((item) => item.toString()));
//     //     _question = data['question']; // Store the question from the response
//     //   });
//     // } else {
//     //   throw Exception('Failed to load jokes');
//     // }
//     if (response.statusCode == 200) {
//       setState(() {
//         apiResponse = json.decode(response.body);
//       });
//     } else {
//       print('Failed to fetch data. Status Code: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Appdrawer(),
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text(
//           'Meme Generation',
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme:
//             const IconThemeData(color: Colors.white), // Drawer icon color
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.search,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               // Implement search functionality here
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Enter your query',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 fetchJokes(_controller.text);
//               },
//               child: Text('Generate Memes'),
//             ),
//             SizedBox(height: 16),
//             if (_question != null)
//               Text(
//                 'Entered Text: $_question',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             SizedBox(height: 8),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _memes.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_memes[index]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//         backgroundColor: Colors.blue,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
//         selectedFontSize: 14,
//         unselectedFontSize: 12,
//         iconSize: 30,
//         showUnselectedLabels: true,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.create),
//             label: 'Create',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark),
//             label: 'Saved',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
