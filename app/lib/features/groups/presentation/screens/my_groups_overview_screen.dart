import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/group_provider.dart';

class MyGroupsOverviewScreen extends StatefulWidget {
  const MyGroupsOverviewScreen({super.key});

  @override
  MyGroupsOverviewScreenState createState() => MyGroupsOverviewScreenState();
}

class MyGroupsOverviewScreenState extends State<MyGroupsOverviewScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load groups when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false).fetchGroups();
    });
  }

  void _filterGroups(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupProvider.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${groupProvider.errorMessage}')),
          );
        }

        final filteredGroups = groupProvider.groups
            .where(
              (group) =>
                  group.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Text(
              'My Groups',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onChanged: _filterGroups,
                  decoration: InputDecoration(
                    hintText: 'Search groups...',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153), // 0.6 * 255 = 153
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153), // 0.6 * 255 = 153
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(group.avatarUrl),
                      ),
                      title: Text(
                        group.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        group.lastMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha(178), // 0.7 * 255 = 178.5
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy HH:mm').format(group.time),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha(178), // 0.7 * 255 = 178.5
                              fontSize: 12,
                            ),
                          ),
                          if (group.unreadCount != null &&
                              group.unreadCount! > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              child: Text(
                                '${group.unreadCount}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        context.push('/groups/detail/${group.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.push('/groups/create');
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        );
      },
    );
  }
}
