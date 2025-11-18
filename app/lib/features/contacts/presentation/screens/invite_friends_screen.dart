import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

import '../../domain/entities/contact.dart'; // Corrected import for Contact entity
import '../notifiers/contact_list_notifier.dart';
import '../notifiers/invite_friends_notifier.dart';
import '../notifiers/user_search_notifier.dart';
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
  late UserSearchNotifier _userSearchNotifier;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userSearchNotifier = Provider.of<UserSearchNotifier>(
        context,
        listen: false,
      );
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
    _searchController.removeListener(_onSearchChanged);
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

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final allContacts = Provider.of<ContactListNotifier>(
      context,
      listen: false,
    ).contacts;

    if (query.isEmpty) {
      // Show existing contacts when no search query
      setState(() {
        _filteredContacts = allContacts;
        _groupAndBuildList();
      });
      _userSearchNotifier.clearSearch();
    } else {
      // Search for users in the system
      _userSearchNotifier.searchUsers(query, allContacts);
    }
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
        .where((email) => email != null && email.isNotEmpty)
        .cast<String>()
        .toList();

    if (inviteeEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('None of the selected contacts have an email address.'),
        ),
      );
      return;
    }

    if (inviteeEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('None of the selected contacts have valid email addresses. Please select contacts with emails.'),
        ),
      );
      return;
    }

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

  void _shareInviteLink() async {
    // Generate a dynamic invite link
    // For now, we'll create a link that can be shared via messaging apps
    // In production, this could be a Firebase Dynamic Link or similar service

    const String baseUrl = 'yourapp://invite'; // App deep link
    const String fallbackUrl = 'https://yourapp.com/invite'; // Web fallback

    const String inviteMessage =
        '''
Join me on Idiot Social Platform!

Download the app and use this link to connect with me:
$baseUrl

Or visit: $fallbackUrl
''';

    try {
      await share_plus.Share.share(
        inviteMessage,
        subject: 'Join me on Idiot Social Platform!',
      );
    } catch (e) {
      // Fallback to basic share if advanced sharing fails
      share_plus.Share.share(inviteMessage);
    }
  }

  Future<void> _addFromAddressBook() async {
    if (await fc.FlutterContacts.requestPermission()) {
      // Get all contacts with email addresses
      List<fc.Contact> allContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Filter contacts that have email addresses
      List<fc.Contact> contactsWithEmails = allContacts
          .where((contact) => contact.emails.isNotEmpty)
          .toList();

      if (!mounted) return;

      if (contactsWithEmails.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts with email addresses found.'),
          ),
        );
        return;
      }

      // Show dialog to select contacts
      await _showContactSelectionDialog(contactsWithEmails);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
    }
  }

  Future<void> _showContactSelectionDialog(List<fc.Contact> contacts) async {
    final selectedContacts = <fc.Contact>{};

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Contacts'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '${contacts.length} contacts with email addresses found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = selectedContacts.contains(contact);
                      final email = contact.emails.isNotEmpty
                          ? contact.emails.first.address
                          : '';

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedContacts.add(contact);
                            } else {
                              selectedContacts.remove(contact);
                            }
                          });
                        },
                        title: Text(contact.displayName),
                        subtitle: Text(email),
                        secondary: CircleAvatar(
                          backgroundImage: contact.photo != null
                              ? MemoryImage(contact.photo!)
                              : null,
                          child: contact.photo == null
                              ? Text(
                                  contact.displayName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedContacts.isEmpty
                  ? null
                  : () {
                      _addContactsToSelection(selectedContacts);
                      Navigator.of(context).pop();
                    },
              child: Text('Add ${selectedContacts.length} Contacts'),
            ),
          ],
        ),
      ),
    );
  }

  void _addContactsToSelection(Set<fc.Contact> selectedDeviceContacts) {
    // Convert device contacts to our Contact model
    for (final deviceContact in selectedDeviceContacts) {
      final email = deviceContact.emails.isNotEmpty
          ? deviceContact.emails.first.address
          : '';
      if (email.isNotEmpty) {
        // Check if we already have this contact in our selected list
        final existingContact = _selectedContacts.firstWhere(
          (contact) => contact.email == email,
          orElse: () => Contact(
            id: '', // We'll use email as temporary ID for now
            name: deviceContact.displayName,
            email: email,
            phoneNumber: deviceContact.phones.isNotEmpty
                ? deviceContact.phones.first.number
                : null,
          ),
        );

        if (existingContact.id.isEmpty) {
          // This is a new contact, add it
          _selectedContacts.add(
            Contact(
              id: email, // Use email as ID for device contacts
              name: deviceContact.displayName,
              email: email,
              phoneNumber: deviceContact.phones.isNotEmpty
                  ? deviceContact.phones.first.number
                  : null,
            ),
          );
        }
      }
    }

    setState(() {}); // Trigger UI update

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${selectedDeviceContacts.length} contacts from address book',
          ),
        ),
      );
    }
  }

  void _scanQrCode() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const QRScannerScreen()))
        .then((value) {
          if (value is String && value.isNotEmpty) {
            if (!mounted) return;
            _handleScannedCode(value);
          }
        });
  }

  void _handleScannedCode(String scannedCode) {
    try {
      // Try to extract token from different possible formats
      String? token;

      // Format 1: Full URL like "yourapp://invite?token=abc123"
      if (scannedCode.contains('token=')) {
        final uri = Uri.parse(scannedCode);
        token = uri.queryParameters['token'];
      }
      // Format 2: Direct token string
      else if (scannedCode.length > 10 && !scannedCode.contains(' ')) {
        // Assume it's a direct token if it's a long string without spaces
        token = scannedCode;
      }

      if (token != null && token.isNotEmpty) {
        // Navigate to invite acceptance screen
        context.push('/invite-accept?token=$token');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid QR code format. Please scan a valid invitation code.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing QR code: $e')));
    }
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
                hintText: 'Search users by name, phone, email, or nickname',
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
            child: Consumer2<ContactListNotifier, UserSearchNotifier>(
              builder: (context, contactNotifier, searchNotifier, child) {
                final hasSearchQuery = _searchController.text.trim().isNotEmpty;

                // Show search results if there's a query
                if (hasSearchQuery) {
                  if (searchNotifier.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (searchNotifier.errorMessage != null) {
                    return Center(
                      child: Text(
                        searchNotifier.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (searchNotifier.searchResults.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: searchNotifier.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchNotifier.searchResults[index];
                      final isSelected = _selectedContacts.contains(user);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              (user.avatarUrl != null &&
                                  user.avatarUrl!.isNotEmpty)
                              ? NetworkImage(user.avatarUrl!)
                              : const AssetImage('assets/images/avatar_s.png')
                                    as ImageProvider,
                        ),
                        title: Text(
                          user.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          user.email ?? 'No email found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                         trailing: Checkbox(
                           value: isSelected,
                           onChanged: user.email != null ? (bool? value) {
                             setState(() {
                               if (value == true) {
                                 _selectedContacts.add(user);
                               } else {
                                 _selectedContacts.remove(user);
                               }
                             });
                           } : null,
                           activeColor: theme.colorScheme.primary,
                           checkColor: theme.colorScheme.onPrimary,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(4),
                           ),
                         ),
                         onTap: user.email != null ? () {
                           setState(() {
                             if (isSelected) {
                               _selectedContacts.remove(user);
                             } else {
                               _selectedContacts.add(user);
                             }
                           });
                         } : null,
                      );
                    },
                  );
                }

                // Show existing contacts when no search query
                if (contactNotifier.isLoading && _filteredContacts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredContacts.isEmpty &&
                    _searchController.text.isEmpty) {
                  _filteredContacts = contactNotifier.contacts;
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
                           onChanged: contact.email != null ? (bool? value) {
                             setState(() {
                               if (value == true) {
                                 _selectedContacts.add(contact);
                               } else {
                                 _selectedContacts.remove(contact);
                               }
                             });
                           } : null,
                           activeColor: theme.colorScheme.primary,
                           checkColor: theme.colorScheme.onPrimary,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(4),
                           ),
                         ),
                         onTap: contact.email != null ? () {
                           setState(() {
                             if (isSelected) {
                               _selectedContacts.remove(contact);
                             } else {
                               _selectedContacts.add(contact);
                             }
                           });
                         } : null,
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
