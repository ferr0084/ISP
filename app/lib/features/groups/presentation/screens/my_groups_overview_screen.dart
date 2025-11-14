import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/group.dart';
import '../providers/group_provider.dart';

class MyGroupsOverviewScreen extends StatefulWidget {
  const MyGroupsOverviewScreen({super.key});

  @override
  _MyGroupsOverviewScreenState createState() => _MyGroupsOverviewScreenState();
}

class _MyGroupsOverviewScreenState extends State<MyGroupsOverviewScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<GroupProvider>(context, listen: false).fetchGroups();
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
        final filteredGroups = groupProvider.groups
            .where((group) => group.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFF1C2128), // Dark background color
          appBar: AppBar(
            backgroundColor: const Color(0xFF1C2128),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: const Text(
              'My Groups',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterGroups,
                  decoration: InputDecoration(
                    hintText: 'Search groups...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2D333B),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        group.lastMessage,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            group.time,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                          if (group.unreadCount != null && group.unreadCount! > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              child: Text(
                                '${group.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        context.push('/groups/detail', extra: group.id);
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
        },
    );
  }
}