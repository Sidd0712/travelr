import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelr/database/chat_service.dart';
import 'package:travelr/database/message_model.dart';
import 'package:travelr/live_travel/live_travel_controller.dart';
import 'package:travelr/live_travel/live_travel_model.dart';
import 'package:travelr/live_travel/live_travel_pane.dart';

class ChatPage extends StatefulWidget {
  final String roomID;
  final String groupName;
  const ChatPage({super.key, required this.roomID, required this.groupName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messagesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserID;
  Map<String, String>? _members;
  final LiveTravelController _controller = LiveTravelController();
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _initializeChatData();
  }

  Future<String> getChatDisplayName({required String roomId}) async {
    final name = await ChatService.getChatGroupName(roomId);
    return name ?? "Unknown Group";
  }

  Future<void> _initializeChatData() async {
    _currentUserID = FirebaseAuth.instance.currentUser?.uid ?? '';
    _members = await ChatService.getMemberProfiles(widget.roomID);

    final name = await getChatDisplayName(roomId: widget.roomID);

    if (!mounted) return;

    setState(() {
      _groupName = name;
    });
  }

  void sendMessage() async {
    final text = _messagesController.text.trim();
    if (text.isEmpty) return;

    _messagesController.clear();

    await ChatService.sendMessage(widget.roomID, text);

    _sendChatNotification(text);

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendChatNotification(String message) async {
    if (_members == null || _currentUserID == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uri = Uri.parse(
      'https://travelr-ml.onrender.com/chat/send',
    );

    final idToken = await user.getIdToken();

    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'room_id': widget.roomID,
        'members': _members!.keys.toList(),
        'message': message,
        'sender_uid': _currentUserID,
        'sender_name': _members![_currentUserID],
        'group_name': _groupName!
      }),
    );

    log(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          const SizedBox(height: 20),
          Text(
            _groupName ?? widget.groupName,
            style: const TextStyle(
                fontSize: 25, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ]),
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            iconSize: 38,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: IconButton(
              icon: const Icon(Icons.route_outlined),
              onPressed: () async {
                if (_controller.session == null) {
                  debugPrint("Calling API...");
                  final uri = Uri.https(
                    'travelr-ml.onrender.com',
                    '/trip/${widget.roomID}',
                  );

                  try {
                    final idToken =
                        await FirebaseAuth.instance.currentUser!.getIdToken();

                    final response = await http.get(
                      uri,
                      headers: {
                        'Authorization': 'Bearer $idToken',
                      },
                    );

                    debugPrint("Recieved Output");

                    if (response.statusCode != 200) {
                      debugPrint("Trip API failed: ${response.body}");
                      return;
                    }

                    final data = json.decode(response.body);
                    log(jsonEncode(data));

                    debugPrint("Starting Controller");
                    final session = await LiveTravelSession.fromTripApi(data);

                    _controller.start(
                      roomId: widget.roomID,
                      userId: _currentUserID!,
                      initialSession: session,
                    );

                    debugPrint("Controller Started");
                  } catch (e) {
                    debugPrint("Trip start failed: $e");
                  }
                } else {
                  _controller.stop();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
          child: Column(
            children: [
              AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final session = _controller.session;
                    if (session == null) return const SizedBox.shrink();

                    return LiveTravelPane(
                      session: session,
                      currentUserId: _currentUserID!,
                    );
                  }),
              Expanded(
                child: _buildMessagesList(),
              ),
              const SizedBox(height: 20),
              _userInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_currentUserID == null || _members == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder(
      stream: ChatService.getMessages(widget.roomID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading..."));
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text("Start a chat..."));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.map((msg) => _buildMessageItem(msg)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(Message data) {
    bool isSent = data.senderID == _currentUserID;
    String message = data.message;
    // print(data.timestamp.toDate().toLocal().toString());

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSent)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 2),
              child: Text(
                _members?[data.senderID] ?? "Unknown Sender",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isSent ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isSent ? const Radius.circular(15) : Radius.zero,
                bottomRight: isSent ? Radius.zero : const Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isSent ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.timestamp
                      .toDate()
                      .toLocal()
                      .toString()
                      .split(' ')[1]
                      .substring(0, 5),
                  style: TextStyle(
                    color: isSent ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              cursorColor: Colors.black,
              controller: _messagesController,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (value) => sendMessage(),
              decoration: const InputDecoration(
                filled: true,
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.all(15),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded),
            onPressed: sendMessage,
            iconSize: 35,
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
