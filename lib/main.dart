// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:meme_app/auth_service.dart';
// import 'package:meme_app/sign_in_screen.dart';
// import 'dart:convert';
// import 'drawer.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(MemeApp());
// }
//
// class MemeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MemeGenerationPage(),
//     );
//   }
// }
//
// class MemeGenerationPage extends StatefulWidget {
//   @override
//   _MemeGenerationPageState createState() => _MemeGenerationPageState();
// }
//
// class _MemeGenerationPageState extends State<MemeGenerationPage> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _controller = TextEditingController();
//   String? _question;
//   List<Map<String, dynamic>> _memes = [];
//   int _selectedIndex = 0;
//   bool _isLoading = false;
//
//   void _onBottomNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     checkUserStatus();
//   }
//
//   // Check if user is logged in
//   void checkUserStatus() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       // Redirect to sign-in if not logged in
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SignInScreen()),
//         );
//       });
//     }
//   }
//
//   // Handle Sign-Out
//   Future<void> handleSignOut() async {
//     await _authService.signOut();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Sign-Out Successful'),
//     ));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SignInScreen()),
//     );
//   }
//
//   Future<void> fetchMemes(String query) async {
//     setState(() {
//       _question = query;
//       _memes = [];
//       _isLoading = false;
//     });
//
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['top_memes'] != null) {
//           setState(() {
//             _memes = List<Map<String, dynamic>>.from(data['top_memes']);
//           });
//         } else {
//           setState(() {
//             _memes = [];
//           });
//         }
//       } else {
//         print('Failed to fetch memes. Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching memes: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
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
//           if (user != null)
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.white),
//               onPressed: handleSignOut,
//             ),
//         ],
//       ),
//       body: user == null
//           ? Center(
//               child: Text(
//                 'Please log in to view memes.',
//                 style: TextStyle(fontSize: 18),
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your query',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => fetchMemes(_controller.text),
//                     child: Text('Generate Memes'),
//                   ),
//                   SizedBox(height: 16),
//                   if (_question != null)
//                     Text(
//                       'Entered Text: $_question',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                   SizedBox(height: 8),
//                   _isLoading
//                       ? CircularProgressIndicator()
//                       : Expanded(
//                           child: ListView.builder(
//                             itemCount: _memes.length,
//                             itemBuilder: (context, index) {
//                               final meme = _memes[index];
//                               return Card(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${meme['text']}',
//                                         style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Emotion: ${meme['emotion']}',
//                                         style: const TextStyle(fontSize: 14),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Image.network(
//                                         'http://10.0.2.2:8000${meme['image']}',
//                                         height: 200,
//                                         width: double.infinity,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (index) {}, // Define navigation logic if needed
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
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:meme_app/auth_service.dart';
// import 'package:meme_app/sign_in_screen.dart';
// import 'dart:convert';
// import 'drawer.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(MemeApp());
// }
//
// class MemeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MemeGenerationPage(),
//     );
//   }
// }
//
// class MemeGenerationPage extends StatefulWidget {
//   @override
//   _MemeGenerationPageState createState() => _MemeGenerationPageState();
// }
//
// class _MemeGenerationPageState extends State<MemeGenerationPage> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _controller = TextEditingController();
//   String? _question;
//   List<String> _memeImages = [];
//   int _selectedIndex = 0;
//   bool _isLoading = false;
//
//   void _onBottomNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     checkUserStatus();
//   }
//
//   // Check if user is logged in
//   void checkUserStatus() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       // Redirect to sign-in if not logged in
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SignInScreen()),
//         );
//       });
//     }
//   }
//
//   // Handle Sign-Out
//   Future<void> handleSignOut() async {
//     await _authService.signOut();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Sign-Out Successful'),
//     ));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SignInScreen()),
//     );
//   }
//
//   Future<void> fetchMemes(String query) async {
//     setState(() {
//       _question = query;
//       _memeImages = [];
//       _isLoading = true;
//     });
//
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['top_memes'] != null) {
//           setState(() {
//             _memeImages = List<String>.from(
//               data['top_memes'].map((meme) => meme['image']),
//             );
//           });
//         } else {
//           setState(() {
//             _memeImages = [];
//           });
//         }
//       } else {
//         print('Failed to fetch memes. Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching memes: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
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
//           if (user != null)
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.white),
//               onPressed: handleSignOut,
//             ),
//         ],
//       ),
//       body: user == null
//           ? Center(
//               child: Text(
//                 'Please log in to view memes.',
//                 style: TextStyle(fontSize: 18),
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your query',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => fetchMemes(_controller.text),
//                     child: Text('Generate Memes'),
//                   ),
//                   SizedBox(height: 16),
//                   if (_question != null)
//                     Text(
//                       'Entered Text: $_question',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                   SizedBox(height: 8),
//                   _isLoading
//                       ? CircularProgressIndicator()
//                       : Expanded(
//                           child: GridView.builder(
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 1,
//                               crossAxisSpacing: 8.0,
//                               mainAxisSpacing: 8.0,
//                             ),
//                             itemCount: _memeImages.length,
//                             itemBuilder: (context, index) {
//                               final imageUrl =
//                                   'http://10.0.2.2:8000${_memeImages[index]}';
//                               print(imageUrl);
//                               return Card(
//                                 elevation:
//                                     4, // Adds a shadow effect for a better look
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       16), // Rounded corners for the card
//                                 ),
//                                 child: Container(
//                                   width: 500,
//                                   height: 500,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.blueAccent, // Border color
//                                       width: 4.0, // Border width
//                                     ),
//                                     borderRadius: BorderRadius.circular(
//                                         12), // Rounded corners for the border
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(
//                                         8), // Ensure the image respects border radius
//                                     child: FittedBox(
//                                       fit: BoxFit
//                                           .cover, // Ensures the image fits within the box
//                                       child: Image.network(
//                                         imageUrl,
//                                         errorBuilder:
//                                             (context, error, stackTrace) =>
//                                                 Center(
//                                           child: Text('Image not available'),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped, // Define navigation logic if needed
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
//

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// // import 'package:share/share.dart'; // Add this package
// import 'package:http/http.dart' as http;
// import 'package:meme_app/auth_service.dart';
// import 'package:meme_app/sign_in_screen.dart';
// import 'dart:convert';
// import 'drawer.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(MemeApp());
// }
//
// class MemeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MemeGenerationPage(),
//     );
//   }
// }
//
// class MemeGenerationPage extends StatefulWidget {
//   @override
//   _MemeGenerationPageState createState() => _MemeGenerationPageState();
// }
//
// class _MemeGenerationPageState extends State<MemeGenerationPage> {
//   final TextEditingController _controller = TextEditingController();
//   String? _question;
//   List<String> _memeImages = [];
//   List<String> _savedImages = []; // List to store saved images
//   int _selectedIndex = 0;
//   bool _isLoading = false;
//   final AuthService _authService = AuthService();
//
//   void _onBottomNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   Future<void> handleSignOut() async {
//     await _authService.signOut();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Sign-Out Successful'),
//     ));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SignInScreen()),
//     );
//   }
//
//   Future<void> fetchMemes(String query) async {
//     setState(() {
//       _question = query;
//       _memeImages = [];
//       _isLoading = true;
//     });
//
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['top_memes'] != null) {
//           setState(() {
//             _memeImages = List<String>.from(
//               data['top_memes'].map((meme) => meme['image']),
//             );
//           });
//         } else {
//           setState(() {
//             _memeImages = [];
//           });
//         }
//       } else {
//         print('Failed to fetch memes. Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching memes: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _showImagePopup(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.network(imageUrl, height: 300, width: 300),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 TextButton.icon(
//                   icon: Icon(Icons.save),
//                   label: Text("Save"),
//                   onPressed: () {
//                     if (!_savedImages.contains(imageUrl)) {
//                       setState(() {
//                         _savedImages.add(imageUrl);
//                       });
//                     }
//                     Navigator.pop(context);
//                   },
//                 ),
//                 TextButton.icon(
//                   icon: Icon(Icons.share),
//                   label: Text("Share"),
//                   onPressed: () {
//                     // Share.share(imageUrl);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSavedImagesTab() {
//     return _savedImages.isEmpty
//         ? Center(child: Text("No saved images yet!"))
//         : GridView.builder(
//             padding: EdgeInsets.all(8),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: _savedImages.length,
//             itemBuilder: (context, index) {
//               final imageUrl = _savedImages[index];
//               return GestureDetector(
//                 onTap: () {
//                   _showSharePopup(imageUrl); // Show popup with share option
//                 },
//                 child: Card(
//                   elevation: 4,
//                   child: Image.network(imageUrl, fit: BoxFit.cover),
//                 ),
//               );
//             },
//           );
//   }
//
//   void _showSharePopup(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.network(imageUrl, height: 300, width: 300),
//             TextButton.icon(
//               icon: Icon(Icons.share),
//               label: Text("Share"),
//               onPressed: () {
//                 // Share.share(imageUrl); // Share the image URL
//                 Navigator.pop(context); // Close the popup after sharing
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     Widget currentTab;
//     if (_selectedIndex == 0) {
//       currentTab = Column(
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: 'Enter your query',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => fetchMemes(_controller.text),
//             child: Text('Generate Memes'),
//           ),
//           SizedBox(height: 16),
//           if (_question != null)
//             Text(
//               'Entered Text: $_question',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           SizedBox(height: 8),
//           _isLoading
//               ? CircularProgressIndicator()
//               : Expanded(
//                   child: GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 1,
//                       crossAxisSpacing: 8.0,
//                       mainAxisSpacing: 8.0,
//                     ),
//                     itemCount: _memeImages.length,
//                     itemBuilder: (context, index) {
//                       final imageUrl =
//                           'http://10.0.2.2:8000${_memeImages[index]}';
//                       return GestureDetector(
//                         onTap: () => _showImagePopup(imageUrl), // Open popup
//                         child: Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.blueAccent,
//                                 width: 4.0,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 imageUrl,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Center(child: Text('Image not available')),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ],
//       );
//     } else if (_selectedIndex == 1) {
//       currentTab = _savedImages.isEmpty
//           ? Center(child: Text('No saved memes.'))
//           : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
//               ),
//               itemCount: _savedImages.length,
//               itemBuilder: (context, index) {
//                 return Image.network(_savedImages[index]);
//               },
//             );
//     } else {
//       currentTab = Center(child: Text('Profile Page'));
//     }
//
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
//           if (user != null)
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.white),
//               onPressed: handleSignOut,
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: currentTab,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//         backgroundColor: Colors.blue,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
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
//
//
//

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        primarySwatch: Colors.orange,
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
  final TextEditingController _controller = TextEditingController();
  String? _question;
  List<String> _memeImages = [];
  List<String> _savedImages = [];
  int _selectedIndex = 0;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // GlobalKey to control the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      // Open the drawer when "Profile" is tapped
      _scaffoldKey.currentState?.openDrawer();
    } else {
      // Switch to other tabs
      setState(() {
        _selectedIndex = index;
      });
    }
  }

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
      _memeImages = [];
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/get_memes/?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['top_memes'] != null) {
          setState(() {
            _memeImages = List<String>.from(
              data['top_memes'].map((meme) => meme['image']),
            );
          });
        } else {
          setState(() {
            _memeImages = [];
          });
        }
      } else {
        print('Failed to fetch memes. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching memes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl, height: 300, width: 300),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.save),
                  label: Text("Save"),
                  onPressed: () {
                    if (!_savedImages.contains(imageUrl)) {
                      setState(() {
                        _savedImages.add(imageUrl);
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.share),
                  label: Text("Share"),
                  onPressed: () {
                    // Implement sharing functionality here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget currentTab;
    if (_selectedIndex == 0) {
      currentTab = Column(
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          SizedBox(height: 8),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _memeImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl =
                          'http://10.0.2.2:8000${_memeImages[index]}';
                      return GestureDetector(
                        onTap: () => _showImagePopup(imageUrl), // Open popup
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
                  ),
                ),
        ],
      );
    } else if (_selectedIndex == 1) {
      currentTab = _savedImages.isEmpty
          ? Center(child: Text('No saved memes.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _savedImages.length,
              itemBuilder: (context, index) {
                return Image.network(_savedImages[index]);
              },
            );
    } else {
      currentTab = Center(child: Text(''));
    }

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentTab,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
