import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<String> suggestions = ["Raj", "Neha", "Nikhil", "Dravid", "Mona"];
  List<String> friendRequests = ["Atharva", "Rahul", "Sneha"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Friend Suggestions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final user = suggestions[index];
                return _buildSuggestionCard(user);
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Friend Requests",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: friendRequests.isEmpty
                ? const Center(child: Text("No friend requests yet"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: friendRequests.length,
                    itemBuilder: (context, index) {
                      final user = friendRequests[index];
                      return _buildRequestCard(user, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String user) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade300,
                child: Text(
                  user[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(user,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    suggestions.remove(user);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(String user, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade400,
          child: Text(
            user[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        title: Text(user, style: const TextStyle(fontSize: 18)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  friendRequests.removeAt(index);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                setState(() {
                  friendRequests.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
