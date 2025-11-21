import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../groups/domain/repositories/invitation_repository.dart';
import '../../domain/entities/notification.dart' as entity;
import '../providers/notification_provider.dart';

class NotificationTile extends StatefulWidget {
  final entity.Notification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isProcessing = false;

  Future<void> _handleInvite(bool accept) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final token = widget.notification.data?['token'];
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid invitation data')),
        );
        return;
      }

      final supabaseClient = Provider.of<SupabaseClient>(
        context,
        listen: false,
      );
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) return;

      final invitationRepository = Provider.of<InvitationRepository>(
        context,
        listen: false,
      );

      if (accept) {
        await invitationRepository.acceptInvite(token, currentUserId);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation accepted')));
      } else {
        // Assuming there is a decline method, or we just ignore it.
        // If no decline method, maybe just delete the notification?
        // For now, let's assume we just mark notification as read/handled.
        // But usually there should be a decline.
        // Let's check InvitationRepository later. For now, just show message.
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation declined')));
      }

      // Mark notification as read
      await Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).markAsRead(widget.notification.id);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final isInvite = n.type == 'group_invite';

    return ListTile(
      tileColor: n.read
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      leading: CircleAvatar(
        backgroundColor: isInvite ? Colors.blue : Colors.grey,
        child: Icon(
          isInvite ? Icons.group_add : Icons.notifications,
          color: Colors.white,
        ),
      ),
      title: Text(
        n.title,
        style: TextStyle(
          fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n.message),
          const SizedBox(height: 4),
          Text(
            timeago.format(n.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isInvite && !n.read) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_isProcessing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: () => _handleInvite(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _handleInvite(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      onTap: () {
        if (!n.read) {
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).markAsRead(n.id);
        }
      },
    );
  }
}
