import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/chat/chat_page.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/login/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Profile? user;
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  late Stream<List<Profile>> allUsers = Stream.value([]);

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    Profile? profile = await ProfilesDatabase.getProfileFromUID(uid);
    setState(() {
      user = profile;
      allUsers = ProfilesDatabase.getProfiles();
    });

    // Debugging: Check if profiles are fetched
    allUsers.listen((profiles) {
      print("Profiles fetched: ${profiles.length}");
      for (var profile in profiles) {
        print("User: ${profile.name}, UID: ${profile.uid}");
      }
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
      _profileScreen(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("travelr",
            style: TextStyle(
                fontFamily: "Northlane", fontSize: 38, color: Colors.black)),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Padding _profileScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text("Profile",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text("Name: ${user?.name ?? 'Loading...'}",
              style: TextStyle(fontSize: 25)),
          SizedBox(height: 5),
          Text("Gender: ${user?.gender ?? 'Loading...'}",
              style: TextStyle(fontSize: 25)),
          SizedBox(height: 5),
          Text("Phone: ${user?.phoneNumber ?? 'Loading...'}",
              style: TextStyle(fontSize: 25)),
          SizedBox(height: 20),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () => _signOut(context),
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(double.maxFinite, 50)),
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
                ),
                child: Text("Sign Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  /// **Fixed `_chatScreen()` using StreamBuilder**
  StreamBuilder<List<Profile>> _chatScreen() {
    return StreamBuilder<List<Profile>>(
      stream: allUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No chats available.'));
        } else {
          List<Profile> profiles = snapshot.data!;
          List<Profile> filteredProfiles = profiles.where((profile) {
            return profile.uid != user?.uid;
          }).toList();

          if (filteredProfiles.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: filteredProfiles.length,
            itemBuilder: (context, index) {
              Profile profile = filteredProfiles[index];

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    profile.name,
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade700,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(profile),
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

  Center _homeScreen() =>
      Center(child: Text("Home Screen", style: TextStyle(fontSize: 24)));
}
