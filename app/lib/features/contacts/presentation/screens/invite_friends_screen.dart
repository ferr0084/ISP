import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/contact.dart'; // Corrected import for Contact entity
import '../notifiers/contact_list_notifier.dart';
import '../notifiers/invite_friends_notifier.dart';
import 'qr_scanner_screen.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];
  final Set<Contact> _selectedContacts = {};
  Map<String, List<Contact>> _groupedContacts = {};
  List<dynamic> _listItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contactListNotifier = Provider.of<ContactListNotifier>(
        context,
        listen: false,
      );
      if (mounted) {
        _filteredContacts = contactListNotifier.contacts;
        _groupAndBuildList();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _groupAndBuildList() {
    _groupedContacts = {};
    for (var contact in _filteredContacts) {
      if (contact.name.isNotEmpty) {
        final firstLetter = contact.name.substring(0, 1).toUpperCase();
        if (_groupedContacts[firstLetter] == null) {
          _groupedContacts[firstLetter] = [];
        }
        _groupedContacts[firstLetter]!.add(contact);
      }
    }

    _listItems = [];
    final sortedKeys = _groupedContacts.keys.toList()..sort();
    for (var key in sortedKeys) {
      _listItems.add(key); // Add header
      _listItems.addAll(_groupedContacts[key]!); // Add contacts for that letter
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    final allContacts = Provider.of<ContactListNotifier>(
      context,
      listen: false,
    ).contacts;
    setState(() {
      _filteredContacts = allContacts.where((contact) {
        return contact.name.toLowerCase().contains(query) ||
            (contact.email?.toLowerCase().contains(query) ?? false);
      }).toList();
      _groupAndBuildList();
    });
  }

  Future<void> _sendInvites() async {
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend to invite.'),
        ),
      );
      return;
    }

    final inviteFriendsNotifier = Provider.of<InviteFriendsNotifier>(
      context,
      listen: false,
    );
    final inviteeEmails = _selectedContacts
        .map((contact) => contact.email)
        .whereType<String>()
        .toList();

    await inviteFriendsNotifier.sendInvites(inviteeEmails);

    if (!mounted) return;
    if (inviteFriendsNotifier.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sending invites: ${inviteFriendsNotifier.errorMessage}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invites sent to ${inviteeEmails.length} friends!'),
        ),
      );
      context.pop();
    }
  }

  void _shareInviteLink() {
    // TODO: Replace with actual dynamic link generation
    SharePlus.instance.share(
      ShareParams(
        subject: 'Join me on Idiot Social Platform!',
        text:
            'Join me on Idiot Social Platform! https://example.com/invite/some_code',
      ),
    );
  }

  Future<void> _addFromAddressBook() async {
    if (await fc.FlutterContacts.requestPermission()) {
      // Get all contacts (lightly fetched)
      List<fc.Contact> contacts = await fc.FlutterContacts.getContacts();

      // TODO: Do something with the contacts, e.g., filter and add to selection
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${contacts.length} contacts.')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
    }
  }

  void _scanQrCode() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const QRScannerScreen()))
        .then((value) {
          if (value is String && value.isNotEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Scanned QR Code: $value')));
            // TODO: Handle the scanned code
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Invite Friends',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedContacts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_selectedContacts.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = _selectedContacts.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  (contact.avatarUrl != null &&
                                      contact.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(contact.avatarUrl!)
                                  : const AssetImage(
                                          'assets/images/avatar_s.png',
                                        )
                                        as ImageProvider,
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedContacts.remove(contact);
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: theme.colorScheme.surface,
                                  child: Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contact.name.split(' ').first,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (255 * 0.6).round(),
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withAlpha(
                    (255 * 0.6).round(),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ContactListNotifier>(
              builder: (context, notifier, child) {
                if (notifier.isLoading && _filteredContacts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredContacts.isEmpty &&
                    _searchController.text.isEmpty) {
                  _filteredContacts = notifier.contacts;
                  _groupAndBuildList();
                }

                if (_listItems.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _listItems.length,
                  itemBuilder: (context, index) {
                    final item = _listItems[index];
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          item,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else if (item is Contact) {
                      final contact = item;
                      final isSelected = _selectedContacts.contains(contact);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              (contact.avatarUrl != null &&
                                  contact.avatarUrl!.isNotEmpty)
                              ? NetworkImage(contact.avatarUrl!)
                              : const AssetImage('assets/images/avatar_s.png')
                                    as ImageProvider,
                        ),
                        title: Text(
                          contact.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          contact.email ?? contact.status,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedContacts.add(contact);
                              } else {
                                _selectedContacts.remove(contact);
                              }
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          checkColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedContacts.remove(contact);
                            } else {
                              _selectedContacts.add(contact);
                            }
                          });
                        },
                      );
                    }
                    return const SizedBox.shrink();
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
                  backgroundColor: _selectedContacts.isNotEmpty
                      ? theme.colorScheme.primary
                      : Colors.grey,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Send Invites (${_selectedContacts.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'OR CONNECT WITH',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildConnectMethod(
                      context,
                      icon: Icons.share,
                      label: 'Share Invite\nLink',
                      onTap: _shareInviteLink,
                    ),
                    _buildConnectMethod(
                      context,
                      icon: Icons.person_add_alt_1,
                      label: 'Add from\nAddress Book',
                      onTap: _addFromAddressBook,
                    ),
                    _buildConnectMethod(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR\nCode',
                      onTap: _scanQrCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectMethod(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
