import 'package:flutter/material.dart';

class Appdrawer extends StatelessWidget {
  const Appdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Keyur Dobariya"),
            accountEmail: const Text("keyurdobariya@gmail.com"),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Image.asset('images/profile.png')),
            ),
            decoration: BoxDecoration(
                color: Colors.blue,
                image:
                    DecorationImage(image: AssetImage("images/profile.png"))),
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text("Upload Images"),
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text("Share"),
          ),
          ListTile(
            leading: Icon(Icons.save),
            title: Text("Saved Memes"),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
          ListTile(
            leading: Icon(Icons.more),
            title: Text("About"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
