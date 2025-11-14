import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A2025),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('James'),
            accountEmail: Text('View Profile'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/globe.png',
              ), // Placeholder
            ),
            decoration: BoxDecoration(color: Color(0xFF1A2025)),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text(
              'Home Page',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble, color: Colors.white),
            title: const Text('Chats', style: TextStyle(color: Colors.white)),
            tileColor: const Color.fromRGBO(0, 0, 255, 0.2),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.white),
            title: const Text('Groups', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event, color: Colors.white),
            title: const Text('Events', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt, color: Colors.white),
            title: const Text(
              'Expenses',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.gamepad, color: Colors.white),
            title: const Text(
              'Idiot Game',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts, color: Colors.white),
            title: const Text(
              'Contacts',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.white),
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(
              value:
                  true, // This should be managed by a state management solution
              onChanged: (bool value) {},
              activeThumbColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
