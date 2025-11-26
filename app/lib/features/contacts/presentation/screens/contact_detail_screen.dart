import 'package:app/features/contacts/domain/entities/contact.dart';
import 'package:app/features/contacts/presentation/notifiers/contact_detail_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/user_avatar.dart';

class ContactDetailScreen extends StatefulWidget {
  final String contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _avatarUrlController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactDetailNotifier>(
        context,
        listen: false,
      ).fetchContact(widget.contactId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _populateControllers(Contact? contact) {
    if (contact != null) {
      _nameController.text = contact.name;
      _phoneNumberController.text = contact.phoneNumber ?? '';
      _emailController.text = contact.email ?? '';
      _avatarUrlController.text = contact.avatarUrl ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactDetailNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (notifier.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${notifier.errorMessage}')),
          );
        }

        final contact = notifier.contact;

        if (contact == null) {
          return const Scaffold(body: Center(child: Text('Contact not found')));
        }

        // Populate controllers when contact data is available
        _populateControllers(contact);

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Contact' : 'Contact Details'),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (_isEditing) {
                    // Save changes
                    final updatedContact = contact.copyWith(
                      name: _nameController.text,
                      phoneNumber: _phoneNumberController.text.isEmpty
                          ? null
                          : _phoneNumberController.text,
                      email: _emailController.text.isEmpty
                          ? null
                          : _emailController.text,
                      avatarUrl: _avatarUrlController.text.isEmpty
                          ? null
                          : _avatarUrlController.text,
                    );
                    await notifier.updateContact(updatedContact);

                    if (notifier.hasError) {
                      _showSnackBar(
                        'Error updating contact: ${notifier.errorMessage}',
                      );
                    } else {
                      _showSnackBar('Contact updated successfully!');
                      setState(() {
                        _isEditing = false;
                      });
                    }
                  } else {
                    if (!mounted) return;
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                 UserAvatar(
                   avatarUrl: contact.avatarUrl,
                   name: contact.name,
                   radius: 50,
                   defaultAssetImage: 'assets/images/avatar_s.png',
                 ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _avatarUrlController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
