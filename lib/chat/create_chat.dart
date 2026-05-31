import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/database/chat_service.dart';
import 'package:travelr/chat/chat_page.dart';

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  final Set<String> participants = {};
  late Stream<Map<String, String>> allUsers = Stream.value({});
  String searchQuery = "";
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allUsers = ProfilesDatabase.getProfilesPartial();
    participants.add(currentUserID);
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (participants.contains(uid)) {
        participants.remove(uid);
      } else {
        participants.add(uid);
      }
    });
  }

  Future<void> _createChat(BuildContext context) async {
    if (participants.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select at least two users to chat with")),
      );
      return;
    }

    final bool isGroup = participants.length > 2;
    final String? groupName = isGroup ? groupNameController.text.trim() : null;

    if (isGroup && (groupName == null || groupName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a group name")),
      );
      return;
    }

    print(participants); // nafnsonfsdklsdflsnflnfds

    final roomID = await ChatService.createChat(
        groupName ?? "Unknown Name", participants.toList());

    print(roomID);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(roomID: roomID, groupName: groupName ?? ""),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Chat",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              cursorColor: colorScheme.primary,
              controller: groupNameController,
              decoration: const InputDecoration(
                hintText: "Group Name",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            Expanded(
              child: StreamBuilder<Map<String, String>>(
                stream: allUsers, // your existing getProfilesPartial stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  final profilesMap = snapshot.data!;
                  final filtered = profilesMap.entries.where((entry) {
                    final uid = entry.key;
                    final name = entry.value.toLowerCase();
                    if (uid == currentUserID) return false;
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final uid = filtered[index].key;
                      final name = filtered[index].value;
                      final isSelected = participants.contains(uid);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? colorScheme.primary
                              : colorScheme.secondaryContainer,
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: colorScheme.onPrimary,
                                )
                              : Icon(
                                  Icons.person_outline,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                        ),
                        title: Text(name, style: textTheme.bodyLarge),
                        onTap: () => _toggleSelection(uid),
                      );
                    },
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => _createChat(context),
              style: ButtonStyle(
                fixedSize: const WidgetStatePropertyAll(
                  Size(double.infinity, 48),
                ),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
              ),
              child: Center(
                child: Text(
                  "Create",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
