import 'package:app/features/idiot_game/presentation/providers/idiot_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/user_avatar.dart';

class NewGameScreen extends StatefulWidget {
  final String? groupId;

  const NewGameScreen({super.key, this.groupId});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final Set<String> _selectedPlayerIds = {};
  String? _loserId;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch players when the screen is first loaded
    Future.microtask(
      () => Provider.of<IdiotGameProvider>(
        context,
        listen: false,
      ).fetchPotentialPlayersData(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGame() async {
    final provider = Provider.of<IdiotGameProvider>(context, listen: false);

    // Validation
    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 players')),
      );
      return;
    }

    if (_loserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who lost the game')),
      );
      return;
    }

    if (!_selectedPlayerIds.contains(_loserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The loser must be one of the selected players'),
        ),
      );
      return;
    }

    // Create the game
    await provider.createNewGame(
      _selectedPlayerIds.toList(),
      _descriptionController.text.isEmpty
          ? 'Game on ${DateTime.now().toString().split(' ')[0]}'
          : _descriptionController.text,
      _loserId!,
      widget.groupId, // Pass null if no group context
      null, // imageUrl will be handled by provider
    );

    if (provider.errorMessage == null && mounted) {
      // Success - navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game created successfully!')),
      );
      context.pop();
    } else if (mounted) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create game'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log New Game')),
      body: Consumer<IdiotGameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.potentialPlayers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null &&
              provider.potentialPlayers.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Players',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.potentialPlayers.length,
                    itemBuilder: (context, index) {
                      final user = provider.potentialPlayers[index];
                      final isSelected = _selectedPlayerIds.contains(user.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedPlayerIds.add(user.id);
                            } else {
                              _selectedPlayerIds.remove(user.id);
                              // If this was the loser, clear loser selection
                              if (_loserId == user.id) {
                                _loserId = null;
                              }
                            }
                          });
                        },
                         secondary: UserAvatar(
                           avatarUrl: user.avatarUrl,
                           name: user.fullName ?? user.email,
                         ),
                        title: Text(user.fullName ?? user.email ?? 'Unknown'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Who\'s the Idiot?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _loserId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select the loser',
                  ),
                  items: _selectedPlayerIds.map((playerId) {
                    final user = provider.potentialPlayers.firstWhere(
                      (p) => p.id == playerId,
                    );
                    return DropdownMenuItem(
                      value: playerId,
                      child: Text(user.fullName ?? user.email ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _loserId = newValue;
                    });
                  },
                 ),
                 const SizedBox(height: 20),
                 const Text(
                   'Capture Idiot Photo (optional)',
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 10),
                 if (provider.capturedImageUrl != null)
                   Column(
                     children: [
                       Image.network(
                         provider.capturedImageUrl!,
                         height: 150,
                         width: 150,
                         fit: BoxFit.cover,
                       ),
                       TextButton(
                         onPressed: () => provider.clearCapturedImage(),
                         child: const Text('Remove Photo'),
                       ),
                     ],
                   )
                 else
                   ElevatedButton.icon(
                     onPressed: provider.isUploadingImage
                         ? null
                         : () => provider.takePhoto(),
                     icon: const Icon(Icons.camera_alt),
                     label: provider.isUploadingImage
                         ? const SizedBox(
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(strokeWidth: 2),
                           )
                         : const Text('Take Photo'),
                   ),
                 const SizedBox(height: 20),
                 TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Game Description (optional)',
                    hintText: 'e.g., Epic showdown at the pub',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Game'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
