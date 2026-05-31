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

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          const SizedBox(height: 16),
          Text(
            _groupName ?? widget.groupName,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            iconSize: 38,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: IconButton(
              icon: Icon(Icons.route_outlined, color: colorScheme.primary),
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
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
              const SizedBox(height: 24),
              _userInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_currentUserID == null || _members == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder(
      stream: ChatService.getMessages(widget.roomID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
              "Loading...",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "Start a chat...",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                _members?[data.senderID] ?? "Unknown Sender",
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isSent
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isSent ? const Radius.circular(18) : Radius.zero,
                bottomRight: isSent ? Radius.zero : const Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: textTheme.bodyLarge?.copyWith(
                    color:
                        isSent ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.timestamp
                      .toDate()
                      .toLocal()
                      .toString()
                      .split(' ')[1]
                      .substring(0, 5),
                  style: textTheme.labelSmall?.copyWith(
                    color: isSent
                        ? colorScheme.onPrimary.withValues(alpha: 0.72)
                        : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              cursorColor: colorScheme.primary,
              controller: _messagesController,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (value) => sendMessage(),
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: colorScheme.onPrimary,
            ),
            onPressed: sendMessage,
            iconSize: 35,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
