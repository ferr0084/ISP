import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/group.dart';
import '../providers/group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
                    const uuid = Uuid();
                    final newGroup = Group(
                      id: uuid.v4(),
                      name: _groupName,
                      avatarUrl: 'assets/images/group_placeholder.png',
                      memberIds: [],
                      lastMessage: 'No messages yet',
                      time: 'Now',
                    );
                    Provider.of<GroupProvider>(context, listen: false)
                        .createGroup(newGroup);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
