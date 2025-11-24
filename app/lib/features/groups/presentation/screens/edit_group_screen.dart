import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/group_provider.dart';
import '../widgets/group_avatar.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  EditGroupScreenState createState() => EditGroupScreenState();
}

class EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _groupName;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.getGroup(widget.groupId);
    if (group != null) {
      _groupName = group.name;
    } else {
      _groupName = '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    final supabase = Supabase.instance.client;
    // Use a dedicated folder for group avatars
    final fileName =
        'group_avatars/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(image.path);

    try {
      await supabase.storage.from('avatars').upload(fileName, file);
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.getGroup(widget.groupId);

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
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        GroupAvatar(
                          radius: 60,
                          avatarUrl: group.avatarUrl,
                          localImage: _selectedImage != null
                              ? File(_selectedImage!.path)
                              : null,
                        ),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Set New Photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
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

                              String? avatarUrl = group.avatarUrl;
                              if (_selectedImage != null) {
                                avatarUrl = await _uploadImage(_selectedImage!);
                                if (avatarUrl == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to upload image'),
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }

                              final updatedGroup = group.copyWith(
                                name: _groupName,
                                avatarUrl: avatarUrl,
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
