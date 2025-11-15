import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Added import
import '../providers/group_provider.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  EditGroupScreenState createState() => EditGroupScreenState();
}

class EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _groupName;

  @override
  void initState() {
    super.initState();
    // We need to fetch the group first to initialize _groupName
    // This assumes that the group will be available by the time initState is called
    // or that the GroupProvider will have fetched it.
    // A more robust solution might involve passing the initial group name
    // as a parameter or using a FutureBuilder/StreamBuilder if the group
    // might not be immediately available.
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.getGroup(widget.groupId);
    if (group != null) {
      _groupName = group.name;
    } else {
      // Handle case where group is not found during initState
      // This scenario should ideally be prevented by proper routing/data loading
      _groupName = ''; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.getGroup(widget.groupId); // Use getGroup

        if (group == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Group not found!')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Group'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _groupName,
                    decoration: const InputDecoration(labelText: 'Group Name'),
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
                    onPressed: groupProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final updatedGroup = group.copyWith(
                                name: _groupName,
                              );
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              await context.read<GroupProvider>().updateGroup(
                                updatedGroup,
                              );
                              if (!mounted) return;
                              if (groupProvider.hasError) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error updating group: ${groupProvider.errorMessage}',
                                    ),
                                  ),
                                );
                              } else {
                                navigator.pop();
                              }
                            }
                          },
                    child: groupProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
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
