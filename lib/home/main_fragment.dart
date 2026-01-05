import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/chat/create_chat.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/home/chat_screen.dart';
import 'package:travelr/live_travel/live_travel_controller.dart';
import 'package:travelr/live_travel/live_travel_pane.dart';
import 'package:travelr/home/profile_page.dart';
import 'package:travelr/profile/update_profile.dart';
import 'package:travelr/recommender/recommendation_model.dart';
import 'package:travelr/recommender/recommender_carousel.dart';
import 'package:travelr/recommender/recommender_service.dart';
import 'package:travelr/friends/friends_page.dart';

class HomeScreen extends StatefulWidget {
  final String parent;
  const HomeScreen({super.key, required this.parent});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Profile? user;
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final LiveTravelController _controller = LiveTravelController();
  OverlayEntry? _carouselOverlay;
  bool _carouselShown = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();

    if (widget.parent == "Sign-In") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 🔥 ALLOW DRAWING BEHIND SYSTEM UI
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
        _loadRecommendations();
      });
    }
  }

  @override
  void dispose() {
    hideRecommenderCarousel();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    if (_carouselShown) return;
    _carouselShown = true;

    final data = await RecommenderService.getRecommendations(uid);

    final List<Recommendation> recommendations =
        (data as List).map((j) => Recommendation.fromJson(j)).toList();

    if (recommendations.isNotEmpty && mounted) {
      showRecommenderCarousel(recommendations);
    }
  }

  void fetchUserProfile() async {
    Profile? profile = await ProfilesDatabase.getProfileFromUID(uid);
    setState(() {
      user = profile;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void showRecommenderCarousel(List<Recommendation> recs) {
    if (_carouselOverlay != null) return;

    _carouselOverlay = OverlayEntry(
      builder: (context) {
        return RecommenderCarousel(
            recommendations: recs,
            onClose: () {
              hideRecommenderCarousel();
            });
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_carouselOverlay!);
  }

  void hideRecommenderCarousel() {
    _carouselOverlay?.remove();
    _carouselOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
    ));

    final List<Widget> pages = [
      _homeScreen(),
      ChatScreen(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfileScreen(
                    user: user!,
                  ),
                ),
              );
            },
          ),
        ],
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

  Widget _homeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final session = _controller.session;
                if (session == null) return const SizedBox.shrink();

                return LiveTravelPane(
                  session: session,
                  currentUserId: uid,
                );
              }),
        ],
      ),
    );
  }
}
