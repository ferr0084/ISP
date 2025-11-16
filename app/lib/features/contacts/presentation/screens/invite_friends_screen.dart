import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/contact.dart'; // Corrected import for Contact entity
import '../notifiers/contact_list_notifier.dart';
import '../notifiers/invite_friends_notifier.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];
  final Set<Contact> _selectedContacts = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filteredContacts = Provider.of<ContactListNotifier>(context, listen: false).contacts;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    final allContacts = Provider.of<ContactListNotifier>(context, listen: false).contacts;
    setState(() {
      _filteredContacts = allContacts.where((contact) {
        return contact.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _sendInvites() async {
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one friend to invite.')),
      );
      return;
    }

    final inviteFriendsNotifier = Provider.of<InviteFriendsNotifier>(context, listen: false);
    final inviteeEmails = _selectedContacts.map((contact) => contact.email).whereType<String>().toList();

    await inviteFriendsNotifier.sendInvites(inviteeEmails);

    if (mounted) {
      if (inviteFriendsNotifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending invites: ${inviteFriendsNotifier.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invites sent to ${inviteeEmails.length} friends!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Invite Friends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
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
          Expanded(
            child: Consumer<ContactListNotifier>(
              builder: (context, notifier, child) {
                if (notifier.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.text.isEmpty && _filteredContacts.isEmpty) {
                  _filteredContacts = notifier.contacts;
                }

                return ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return CheckboxListTile(
                      title: Text(
                        contact.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        contact.status,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                        ),
                      ),
                      secondary: CircleAvatar(
                        radius: 20,
                        backgroundImage: (contact.avatarUrl != null &&
                                contact.avatarUrl!.isNotEmpty)
                            ? NetworkImage(contact.avatarUrl!)
                            : const AssetImage(
                                    'assets/images/avatar_s.png',
                                  )
                                  as ImageProvider,
                      ),
                      value: _selectedContacts.contains(contact),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedContacts.add(contact);
                          } else {
                            _selectedContacts.remove(contact);
                          }
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedContacts.isNotEmpty ? _sendInvites : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Send Invites (${_selectedContacts.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
