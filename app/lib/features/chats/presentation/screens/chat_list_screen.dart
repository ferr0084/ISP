import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:app/core/di/service_locator.dart';
import '../providers/chat_provider.dart';
import 'chat_creation_screen.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (_) => sl<ChatProvider>(),
      child: Scaffold(
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
            'Chats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Text('Error: ${provider.error}'),
              );
            }

            final chats = provider.chats;

            if (chats.isEmpty) {
              return const Center(
                child: Text('No chats yet. Start a conversation!'),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    chat.name ?? 'Unnamed Chat',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Tap to open chat', // TODO: Show last message
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: Text(
                    _formatTime(chat.updatedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          chatId: chat.id,
                          chatName: chat.name ?? 'Chat',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChatCreationScreen(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}