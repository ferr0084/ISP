import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/group.dart';
import '../providers/group_provider.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.groups
            .firstWhere((group) => group.id == widget.groupId);
        _groupName = group.name;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Group'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _groupName,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _groupName = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final updatedGroup = Group(
                          id: group.id,
                          name: _groupName,
                          avatarUrl: group.avatarUrl,
                          memberIds: group.memberIds,
                          lastMessage: group.lastMessage,
                          time: group.time,
                          unreadCount: group.unreadCount,
                        );
                        Provider.of<GroupProvider>(context, listen: false)
                            .updateGroup(updatedGroup);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
