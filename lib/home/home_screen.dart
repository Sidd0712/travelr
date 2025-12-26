import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/chat/chat_page.dart';
import 'package:travelr/chat/create_chat.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/login/login.dart';
import 'package:travelr/profile/profile_page.dart';
import 'package:travelr/requests/friends_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Profile? user;
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    Profile? profile = await ProfilesDatabase.getProfileFromUID(uid);
    setState(() {
      user = profile;
    });
  }

  void _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
    ));

    final List<Widget> pages = [
      _homeScreen(),
      _chatScreen(),
      FriendsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("travelr",
            style: TextStyle(
                fontFamily: "Northlane", fontSize: 38, color: Colors.black)),
        centerTitle: true,
        leading: SizedBox(),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateChatPage()));
              },
              child: Icon(Icons.add_rounded, color: Colors.white, size: 36))
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_add), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _chatScreen() {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('members', arrayContains: currentUserID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No groups available.'));
        } else {
          final groups = snapshot.data!.docs;

          //Random Insane Big-Brain Calcs Here

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index].data();
              final roomId = groups[index].id;
              final groupName = group['groupName'] ?? "Unnamed Group";
              final lastMessage = group['lastMessage'];
              final lastMessageTime = group['lastMessageTime']
                  .toDate()
                  .toLocal()
                  .toString()
                  .split(' ')[1]
                  .substring(0, 5);

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    groupName,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(lastMessageTime),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade700,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          roomID: roomId,
                          groupName: groupName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _homeScreen() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // safe bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Currently Travelling With ---
          const Text(
            "Currently Travelling With",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.08,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          "Y",
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Yash Ghogale",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Route: Ghatkopar → Andheri",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: Text(
                          "Next Rendezvous: Ghatkopar Metro Station",
                          style: TextStyle(fontSize: 16),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "ETA: 7 mins",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Current Location ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Current Location: Vikhroli Station",
                          style: TextStyle(fontSize: 16),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- Side Note / Chef's Note ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.sticky_note_2, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Running a few mins late, will join at the back entrance.",
                            style: TextStyle(fontSize: 15),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- Scheduled Commutes ---
          const Text(
            "Scheduled Commutes Today",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text("Andheri → Mulund"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Companion: Siddhant Patel"),
                  Text("Start Time: 5:00 PM"),
                ],
              ),
              trailing: const Text("in 17 hrs"),
            ),
          ),

          const SizedBox(height: 30),

          // --- Nearby Travellers ---
          const Text(
            "Nearby Travellers",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Text("R", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.green,
                child: Text("P", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text("A", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "3 people are travelling from Mulund → Andheri now",
                  style: TextStyle(fontSize: 16),
                  softWrap: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
