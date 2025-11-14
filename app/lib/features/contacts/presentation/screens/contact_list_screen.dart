import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Contact {
  final String name;
  final String avatarUrl;
  final String status;
  final bool isOnline;

  Contact({
    required this.name,
    required this.avatarUrl,
    required this.status,
    this.isOnline = false,
  });
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  // Dummy data for contacts
  final List<Contact> _allContacts = [
    Contact(
      name: 'Aaron Davis',
      avatarUrl: 'assets/images/avatar_chris.png', // Placeholder
      status: 'last seen recently',
      isOnline: true,
    ),
    Contact(
      name: 'Abigail Harris',
      avatarUrl: 'assets/images/avatar_jessica.png', // Placeholder
      status: 'last seen yesterday at 10:42 PM',
    ),
    Contact(
      name: 'Benjamin Clark',
      avatarUrl: 'assets/images/avatar_david.png', // Placeholder
      status: 'last seen a long time ago',
    ),
    Contact(
      name: 'Chloe Lewis',
      avatarUrl: 'assets/images/avatar_maria.png', // Placeholder
      status: 'online',
      isOnline: true,
    ),
    Contact(
      name: 'Christopher Walker',
      avatarUrl: 'assets/images/avatar_james.png', // Placeholder
      status: 'last seen on Tuesday',
    ),
    Contact(
      name: 'David Smith',
      avatarUrl: 'assets/images/avatar_david.png', // Placeholder
      status: 'online',
      isOnline: true,
    ),
    Contact(
      name: 'Emily White',
      avatarUrl: 'assets/images/avatar_jessica.png', // Placeholder
      status: 'last seen recently',
    ),
    Contact(
      name: 'Frank Green',
      avatarUrl: 'assets/images/avatar_chris.png', // Placeholder
      status: 'last seen a long time ago',
    ),
    Contact(
      name: 'Grace Hall',
      avatarUrl: 'assets/images/avatar_maria.png', // Placeholder
      status: 'online',
      isOnline: true,
    ),
    Contact(
      name: 'Henry King',
      avatarUrl: 'assets/images/avatar_james.png', // Placeholder
      status: 'last seen on Monday',
    ),
  ];

  // Group contacts by the first letter of their name
  Map<String, List<Contact>> _groupedContacts = {};
  List<String> _alphabet = [];

  @override
  void initState() {
    super.initState();
    _groupContacts();
  }

  void _groupContacts() {
    _allContacts.sort((a, b) => a.name.compareTo(b.name));
    for (var contact in _allContacts) {
      final firstLetter = contact.name[0].toUpperCase();
      if (!_groupedContacts.containsKey(firstLetter)) {
        _groupedContacts[firstLetter] = [];
      }
      _groupedContacts[firstLetter]!.add(contact);
    }
    _alphabet = _groupedContacts.keys.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2128), // Dark background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2128), // Dark background color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop(); // Navigate back using go_router
          },
        ),
        title: const Text(
          'Contacts',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Implement add contact functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white), // Text color for input
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2D333B), // Darker background for search bar
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
                title: const Text(
                  'Invite Friends',
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
                onTap: () {
                  // TODO: Implement invite friends functionality
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _alphabet.length,
                  itemBuilder: (context, index) {
                    final String letter = _alphabet[index];
                    final List<Contact> contacts = _groupedContacts[letter]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ...contacts.map((contact) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(contact.avatarUrl),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              contact.status,
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: contact.isOnline
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              // TODO: Implement contact detail view
                            },
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _alphabet.map((letter) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Implement scrolling to the letter
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                      child: Text(
                        letter,
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
