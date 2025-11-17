import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/core/di/service_locator.dart';
import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/presentation/notifiers/contact_list_notifier.dart';
import '../providers/chat_provider.dart';

class ChatCreationScreen extends StatefulWidget {
  const ChatCreationScreen({super.key});

  @override
  State<ChatCreationScreen> createState() => _ChatCreationScreenState();
}

class _ChatCreationScreenState extends State<ChatCreationScreen> {
  final Set<String> _selectedContactIds = {};
  final TextEditingController _chatNameController = TextEditingController();

  @override
  void dispose() {
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactListNotifier>(
          create: (_) => sl<ContactListNotifier>(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => sl<ChatProvider>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Chat'),
          actions: [
            Consumer2<ChatProvider, ContactListNotifier>(
              builder: (context, chatProvider, contactProvider, child) {
                final isLoading = chatProvider.isLoading || contactProvider.isLoading;
                final canCreate = _selectedContactIds.isNotEmpty && !isLoading;

                return TextButton(
                  onPressed: canCreate ? _createChat : null,
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: canCreate
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_selectedContactIds.length > 1) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _chatNameController,
                  decoration: const InputDecoration(
                    labelText: 'Chat Name (optional)',
                    hintText: 'Enter a name for the group chat',
                  ),
                ),
              ),
              const Divider(),
            ],
            Expanded(
              child: Consumer<ContactListNotifier>(
                builder: (context, notifier, child) {
                  if (notifier.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final contacts = notifier.contacts;

                  if (contacts.isEmpty) {
                    return const Center(
                      child: Text('No contacts available'),
                    );
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = _selectedContactIds.contains(contact.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedContactIds.add(contact.id);
                            } else {
                              _selectedContactIds.remove(contact.id);
                            }
                          });
                        },
                        title: Text(contact.name),
                        subtitle: Text(contact.phoneNumber ?? ''),
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            contact.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createChat() async {
    final selectedIds = _selectedContactIds.toList();
    final chatName = _chatNameController.text.trim().isEmpty
        ? null
        : _chatNameController.text.trim();

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.createChat(chatName, selectedIds);

    if (mounted) {
      if (chatProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${chatProvider.error}')),
        );
      } else {
        Navigator.of(context).pop(); // Go back to chat list
      }
    }
  }
}