import 'package:app/features/idiot_game/presentation/providers/idiot_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/user_avatar.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdiotGameProvider>().fetchGameDetailsData(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Details')),
      body: Consumer<IdiotGameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedGameDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null &&
              provider.selectedGameDetails == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        provider.fetchGameDetailsData(widget.gameId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final gameDetails = provider.selectedGameDetails;
          if (gameDetails == null) {
            return const Center(child: Text('No game details available'));
          }

          final game = gameDetails.game;
          final loser = gameDetails.loser;
          final participants = gameDetails.participants;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMMM d, y').format(game.gameDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (game.description != null &&
                              game.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              game.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (game.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                game.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current Idiot Section
                  if (loser != null) ...[
                    const Text(
                      'The Idiot',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            UserAvatar(
                              avatarUrl: loser.userProfile.avatarUrl,
                              name: loser.userProfile.fullName,
                              radius: 30,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loser.userProfile.fullName ??
                                        loser.userProfile.email ??
                                        'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (loser.userProfile.email != null &&
                                      loser.userProfile.fullName != null)
                                    Text(
                                      loser.userProfile.email!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.red,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // All Participants Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Participants',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(label: Text('${participants.length} players')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Participants List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      final isLoser = participant.isLoser;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: UserAvatar(
                            avatarUrl: participant.userProfile.avatarUrl,
                            name:
                                participant.userProfile.fullName ??
                                participant.userProfile.email,
                          ),
                          title: Text(
                            participant.userProfile.fullName ??
                                participant.userProfile.email ??
                                'Unknown',
                          ),
                          subtitle:
                              participant.userProfile.email != null &&
                                  participant.userProfile.fullName != null
                              ? Text(participant.userProfile.email!)
                              : null,
                          trailing: isLoser
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Loser',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade400,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
