import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profile_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  Map<String, String> suggestions = {};
  Map<String, String> friendRequests = {};

  @override
  void initState() {
    super.initState();
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    _loadData(currentUserID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final uid = suggestions.keys.elementAt(index);
                final name = suggestions[uid]!;
                return _buildSuggestionCard(uid, name);
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
                      final uid = friendRequests.keys.elementAt(index);
                      final name = friendRequests[uid]!;
                      return _buildRequestCard(uid, name);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String uid, String name) {
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
                  name[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text("Add", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final currentUserID = FirebaseAuth.instance.currentUser!.uid;

                  await ProfilesDatabase.sendFriendRequest(currentUserID, uid);

                  setState(() {
                    suggestions.remove(uid);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(String uid, String name) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade400,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        title: Text(name, style: const TextStyle(fontSize: 18)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                final currentUserID = FirebaseAuth.instance.currentUser!.uid;
                await ProfilesDatabase.rejectFriendRequest(currentUserID, uid);
                setState(() {
                  friendRequests.remove(uid);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                final currentUserID = FirebaseAuth.instance.currentUser!.uid;
                await ProfilesDatabase.acceptFriendRequest(currentUserID, uid);
                setState(() {
                  friendRequests.remove(uid);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData(String currentUserID) async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    Profile? user = await ProfilesDatabase.getProfileFromUID(uid);
    var allProfiles = await ProfilesDatabase.getProfilesPartial().first;
    var friends = user!.friends;

    Map<String, String> requestsMap = {};
    for (String requestUid in user.friendRequests) {
      Profile? profile = await ProfilesDatabase.getProfileFromUID(requestUid);
      if (profile != null) {
        requestsMap[requestUid] = profile.name;
      }
    }

    setState(() {
      suggestions = Map.from(allProfiles)
        ..removeWhere((key, value) =>
            friends.contains(key) ||
            key == uid ||
            requestsMap.containsKey(key));
      friendRequests = requestsMap;
    });

    print("Suggestions: $suggestions");
    print("Friend Requests: $friendRequests");
  }
}
