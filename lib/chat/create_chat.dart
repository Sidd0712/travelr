import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_model.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("New Chat"),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.black,
              controller: groupNameController,
              decoration: const InputDecoration(
                filled: true,
                hintText: "Group Name",
                contentPadding: EdgeInsets.all(15),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                filled: true,
                hintText: "Search contacts...",
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.all(15),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
                          backgroundColor:
                              isSelected ? Colors.blue : Colors.grey.shade700,
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white)
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(name),
                        onTap: () => _toggleSelection(uid),
                      );
                    },
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => _createChat(context),
              style: const ButtonStyle(
                fixedSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              child: Center(
                child: Text(
                  "Create",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
