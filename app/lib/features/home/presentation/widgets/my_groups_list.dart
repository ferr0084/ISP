import 'package:app/features/home/domain/group.dart';
import 'package:flutter/material.dart';

class MyGroupsList extends StatelessWidget {
  const MyGroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final groups = [
      Group(
        name: 'Design Team',
        description: '5 new messages',
        iconUrl: 'assets/images/globe.png',
      ),
      Group(
        name: 'Project Phoenix',
        description: 'Kick-off meeting today @ 2:30 PM',
        iconUrl: 'assets/images/globe.png',
      ),
      Group(
        name: 'Weekend Trip',
        description: 'You owe \$45 for gas',
        iconUrl: 'assets/images/globe.png',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Groups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: AssetImage(group.iconUrl)),
              title: Text(
                group.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                group.description,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
