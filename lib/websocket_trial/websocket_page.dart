import 'package:flutter/material.dart';
import 'package:travelr/websocket_trial/live_travel_controller.dart';

class WebsocketTrialPage extends StatefulWidget {
  const WebsocketTrialPage({super.key});

  @override
  State<WebsocketTrialPage> createState() => _WebsocketTrialPageState();
}

class _WebsocketTrialPageState extends State<WebsocketTrialPage> {
  final controller = LiveTravelController();

  final TextEditingController userIdController =
      TextEditingController(text: "1001");

  bool connected = false;

  @override
  void dispose() {
    controller.stop();
    userIdController.dispose();
    super.dispose();
  }

  void _connect() {
    final userId = userIdController.text.trim();
    if (userId.isEmpty) return;
    debugPrint("Connecting...");
    controller.start("1", userId);
    setState(() => connected = true);
  }

  void _disconnect() {
    controller.stop();
    setState(() => connected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("travelr")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- USER INPUT ----------------
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: "User ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: connected ? null : _connect,
                  child: const Text("Connect"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: connected ? _disconnect : null,
                  child: const Text("Disconnect"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------------- LIVE DATA ----------------
            ValueListenableBuilder(
              valueListenable: controller.selfLocation,
              builder: (_, pos, __) => Text(
                "Self: ${pos == null ? 'Waiting...' : '${pos.latitude}, ${pos.longitude}'}",
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: controller.otherUserLocation,
              builder: (_, loc, __) => Text(
                "Other User: ${loc ?? 'Waiting...'}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
