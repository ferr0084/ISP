import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added import
import 'package:provider/provider.dart';

import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/contact.dart';
import '../notifiers/contact_list_notifier.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  ContactListScreenState createState() => ContactListScreenState();
}

class ContactListScreenState extends State<ContactListScreen> {
  // Group contacts by the first letter of their name
  final Map<String, List<Contact>> _groupedContacts = {};
  List<String> _alphabet = [];

  void _groupContacts(List<Contact> contacts) {
    _groupedContacts.clear();
    contacts.sort((a, b) => a.name.compareTo(b.name));
    for (var contact in contacts) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Contacts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [],
      ),
      body: Consumer<ContactListNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          _groupContacts(notifier.contacts);

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(153),
                            ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardTheme.color,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    title: Text(
                      'Invite Friends',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      context.push('/contacts/invite');
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _alphabet.length,
                      itemBuilder: (context, index) {
                        final String letter = _alphabet[index];
                        final List<Contact> contacts =
                            _groupedContacts[letter]!;
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                            ...contacts.map((contact) {
                              return ListTile(
                                 leading: UserAvatar(
                                   avatarUrl: contact.avatarUrl,
                                   name: contact.name,
                                   radius: 50,
                                   defaultAssetImage: 'assets/images/avatar_s.png',
                                 ),
                                title: Text(
                                  contact.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                subtitle: Text(
                                  contact.status,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(178),
                                      ),
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
                                  context.push(
                                    '/contacts/detail/${contact.id}',
                                  );
                                },
                              );
                            }),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 2.0,
                            horizontal: 8.0,
                          ),
                          child: Text(
                            letter,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
