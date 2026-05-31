import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/friends/friends_service.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Friend Suggestions",
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Friend Requests",
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: friendRequests.isEmpty
                ? Center(
                    child: Text(
                      "No friend requests yet",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  name[0].toUpperCase(),
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  )),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  "Add",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Text(
            name[0].toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(name, style: textTheme.titleMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.close_rounded, color: colorScheme.error),
              onPressed: () async {
                // TODO: Add remove logic here
                setState(() {
                  friendRequests.remove(uid);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.check_rounded, color: colorScheme.primary),
              onPressed: () async {
                await FriendsService.acceptFriendRequest(uid);
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Get pending requests from backend
    final pendingRequests = await FriendsService.getPendingRequests();

    // Get friend list from backend
    final friends = await FriendsService.listFriends();

    // Load profiles for pending requests
    Map<String, String> requestsMap = {};
    for (final req in pendingRequests) {
      final profile = await ProfilesDatabase.getProfileFromUID(req.fromUid);
      if (profile != null) {
        requestsMap[req.fromUid] = profile.name;
      }
    }

    setState(() {
      friendRequests = requestsMap;

      suggestions = Map.from(requestsMap)
        ..removeWhere(
          (key, _) =>
              key == uid ||
              friends.contains(key) ||
              friendRequests.containsKey(key),
        );
    });

    print("Suggestions: $suggestions");
    print("Friend Requests: $friendRequests");
  }
}
