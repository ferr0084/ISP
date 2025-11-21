import 'package:app/features/idiot_game/presentation/providers/idiot_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<IdiotGameProvider>(
        context,
        listen: false,
      ).fetchGameHistoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game History')),
      body: Consumer<IdiotGameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.gameHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.gameHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchGameHistoryData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchGameHistoryData();
            },
            child: provider.gameHistory.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No games found')),
                    ],
                  )
                : ListView.builder(
                    itemCount: provider.gameHistory.length,
                    itemBuilder: (context, index) {
                      final game = provider.gameHistory[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(game.description ?? 'Game'),
                          subtitle: Text(
                            game.gameDate.toString().split(' ')[0],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/idiot-game/details/${game.id}');
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
