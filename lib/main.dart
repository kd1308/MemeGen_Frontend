// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
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
//         primarySwatch: Colors.orange,
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
//   List<String> _savedImages = [];
//   int _selectedIndex = 0;
//   bool _isLoading = false;
//   final AuthService _authService = AuthService();
//
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Get the current user
//   User? get currentUser => FirebaseAuth.instance.currentUser;
//
//   // GlobalKey to control the Scaffold
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   void _onBottomNavTapped(int index) {
//     if (index == 2) {
//       // Open the drawer when "Profile" is tapped
//       _scaffoldKey.currentState?.openDrawer();
//     } else {
//       // Switch to other tabs
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
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
//   Future<void> fetchSavedMemes() async {
//     if (currentUser != null) {
//       final userDoc =
//           await _firestore.collection('users').doc(currentUser!.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _savedImages = List<String>.from(userDoc['saved_memes'] ?? []);
//         });
//       }
//     }
//   }
//
//   Future<void> saveMeme(String imageUrl) async {
//     if (currentUser != null) {
//       final userDoc = _firestore.collection('users').doc(currentUser!.uid);
//       await userDoc.set({
//         'saved_memes': FieldValue.arrayUnion([imageUrl]),
//       }, SetOptions(merge: true));
//       setState(() {
//         _savedImages.add(imageUrl);
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
//                       saveMeme(imageUrl);
//                     }
//                     Navigator.pop(context);
//                   },
//                 ),
//                 TextButton.icon(
//                   icon: Icon(Icons.share),
//                   label: Text("Share"),
//                   onPressed: () {
//                     // Implement sharing functionality here
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
//   @override
//   void initState() {
//     super.initState();
//     fetchSavedMemes(); // Fetch saved memes when the page loads
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
//       currentTab = Center(child: Text(''));
//     }
//
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: Appdrawer(),
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Row(
//           children: [
//             Icon(Icons.emoji_emotions, color: Colors.white),
//             SizedBox(width: 8),
//             Text(
//               'Meme Generation',
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         iconTheme: IconThemeData(color: Colors.white),
//         actions: [
//           if (user != null)
//             IconButton(
//               icon: Icon(Icons.logout),
//               onPressed: handleSignOut,
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: currentTab,
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.create_outlined),
//             label: 'Create',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark_border),
//             label: 'Saved',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:meme_app/FullImagePage.dart';
import 'package:meme_app/auth_service.dart';
import 'package:meme_app/sign_in_screen.dart';
import 'dart:convert';
import 'bottom_navbar.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
        if (data['top_memes'] != null && data['top_memes'].isNotEmpty) {
          setState(() {
            _memeImages = List<String>.from(
              data['top_memes'].map((meme) => meme['image']),
            );
          });
        } else {
          // No memes found, show popup
          setState(() {
            _memeImages = [];
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('No Memes Found!'),
                content: const Text(
                  'Oops! We couldn’t find any memes for your query. Try again with something different.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay'),
                  ),
                ],
              );
            },
          );
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

  Future<void> fetchSavedMemes() async {
    if (currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _savedImages = List<String>.from(userDoc['saved_memes'] ?? []);
        });
      }
    }
  }

  Future<void> saveMeme(String imageUrl) async {
    if (currentUser != null) {
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      await userDoc.set({
        'saved_memes': FieldValue.arrayUnion([imageUrl]),
      }, SetOptions(merge: true));
      setState(() {
        _savedImages.add(imageUrl);
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
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: () {
                    if (!_savedImages.contains(imageUrl)) {
                      saveMeme(imageUrl);
                    }
                    Navigator.pop(context);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text("view"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullImagePage(
                                imgUrl: imageUrl,
                              )),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
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
  void initState() {
    super.initState();
    fetchSavedMemes(); // Fetch saved memes when the page loads
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
              labelText: 'What’s on your mind today? 🤔',
              hintText: 'Type something funny or interesting...',
              prefixIcon: const Icon(Icons.question_answer, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isEmpty) {
                // Show error if input is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter some text to generate memes!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                fetchMemes(_controller.text);
              }
            },
            child: const Text('Generate Memes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, // Text color

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : _memeImages.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text(''), // Placeholder if needed later
                      ),
                    )
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _memeImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl =
                              'http://10.0.2.2:8000${_memeImages[index]}';
                          return GestureDetector(
                            onTap: () =>
                                _showImagePopup(imageUrl), // Open popup
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Center(
                                            child: Text('Image not available')),
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
          ? const Center(child: Text('No saved memes.'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _savedImages.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullImagePage(
                                  imgUrl: _savedImages[index],
                                )),
                      );
                    },
                    child: Image.network(_savedImages[index]));
              },
            );
    } else {
      currentTab = const Center(child: Text(''));
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEBF3FA),
      drawer: const Appdrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Row(
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: handleSignOut,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentTab,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
