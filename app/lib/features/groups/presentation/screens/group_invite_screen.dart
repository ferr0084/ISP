import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:app/features/profile/domain/entities/user_profile.dart'; // Corrected import for UserProfile entity
import '../notifiers/group_invite_notifier.dart'; // Changed to GroupInviteNotifier
import 'package:app/core/di/service_locator.dart'; // For sl

class GroupInviteScreen extends StatefulWidget {
  final String groupId;

  const GroupInviteScreen({super.key, required this.groupId});

  @override
  State<GroupInviteScreen> createState() => _GroupInviteScreenState();
}

class _GroupInviteScreenState extends State<GroupInviteScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<UserProfile> _selectedUsers = {};
  late GroupInviteNotifier _groupInviteNotifier; // Renamed to _groupInviteNotifier

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _groupInviteNotifier = sl<GroupInviteNotifier>(); // Initialize with sl
    // Since we are not using ContactListNotifier or UserSearchNotifier directly here,
    // _groupInviteNotifier will handle the user search.
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _groupInviteNotifier.dispose(); // Dispose the notifier
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _groupInviteNotifier.searchUsers(query, widget.groupId); // Pass groupId for group-specific search
    } else {
      _groupInviteNotifier.clearSearch();
    }
  }

  Future<void> _sendInvites() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one user to invite.'),
        ),
      );
      return;
    }

    final inviteeEmails = _selectedUsers
        .map((user) => user.email)
        .where((email) => email != null && email.isNotEmpty)
        .cast<String>()
        .toList();

    if (inviteeEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('None of the selected users have an email address.'),
        ),
      );
      return;
    }

    await _groupInviteNotifier.sendGroupInvites(inviteeEmails, widget.groupId); // Use sendGroupInvites

    if (!mounted) return;
    if (_groupInviteNotifier.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sending invites: ${_groupInviteNotifier.errorMessage}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invites sent to ${inviteeEmails.length} users!'),
        ),
      );
      context.pop(); // Pop back to the group detail screen
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
          'Invite to Group',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ChangeNotifierProvider<GroupInviteNotifier>.value(
        value: _groupInviteNotifier,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Selected',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_selectedUsers.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _selectedUsers.elementAt(index);
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
                                    (user.avatarUrl != null &&
                                            user.avatarUrl!.isNotEmpty)
                                        ? NetworkImage(user.avatarUrl!)
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
                                      _selectedUsers.remove(user);
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
                            user.fullName?.split(' ').first ?? '',
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
                  hintText: 'Search users by name or email',
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
              child: Consumer<GroupInviteNotifier>(
                builder: (context, notifier, child) {
                  if (_searchController.text.trim().isEmpty) {
                    return const Center(child: Text('Start typing to search for users.'));
                  }

                  if (notifier.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (notifier.errorMessage != null) {
                    return Center(
                      child: Text(
                        notifier.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (notifier.searchResults.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: notifier.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = notifier.searchResults[index];
                      final isSelected = _selectedUsers.contains(user);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              (user.avatarUrl != null &&
                                      user.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(user.avatarUrl!)
                                  : const AssetImage(
                                          'assets/images/avatar_s.png')
                                          as ImageProvider,
                        ),
                        title: Text(
                          user.fullName ?? 'Unknown User',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          user.email ?? 'No Email',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedUsers.add(user);
                              } else {
                                _selectedUsers.remove(user);
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
                              _selectedUsers.remove(user);
                            } else {
                              _selectedUsers.add(user);
                            }
                          });
                        },
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
                  onPressed: _selectedUsers.isNotEmpty ? _sendInvites : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedUsers.isNotEmpty
                        ? theme.colorScheme.primary
                        : Colors.grey,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Send Invites (${_selectedUsers.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}