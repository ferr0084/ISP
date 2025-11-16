import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/invitation_repository.dart'; // Assuming InvitationRepository is needed

class InviteAcceptScreen extends StatefulWidget {
  final String? token;

  const InviteAcceptScreen({super.key, required this.token});

  @override
  State<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends State<InviteAcceptScreen> {
  String _statusMessage = 'Processing invitation...';
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _processInvitation();
  }

  Future<void> _processInvitation() async {
    if (widget.token == null) {
      setState(() {
        _statusMessage = 'Invalid invitation link: Token missing.';
        _isError = true;
        _isLoading = false;
      });
      return;
    }

    final supabaseClient = Provider.of<SupabaseClient>(context, listen: false);
    final currentUserId = supabaseClient.auth.currentUser?.id;

    if (currentUserId == null) {
      setState(() {
        _statusMessage = 'Please log in to accept the invitation.';
        _isError = true;
        _isLoading = false;
      });
      // Optionally, redirect to login page
      // context.go('/login');
      return;
    }

    try {
      final invitationRepository = Provider.of<InvitationRepository>(
        context,
        listen: false,
      );
      await invitationRepository.acceptInvite(widget.token!, currentUserId);
      setState(() {
        _statusMessage = 'Invitation accepted successfully!';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to accept invitation: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      // After a short delay, navigate to home or contacts
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.go('/contacts'); // Or '/home'
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accept Invitation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading)
                Icon(
                  _isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: _isError ? Colors.red : Colors.green,
                  size: 80,
                ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!_isLoading && _isError) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.go('/home'); // Allow user to go home
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
