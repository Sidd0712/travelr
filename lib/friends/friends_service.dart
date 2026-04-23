import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:travelr/friends/friend_model.dart';

class FriendsService {
  static const String _baseUrl = "travelr-ml.onrender.com";

  /// 🔐 Get Firebase ID Token
  static Future<String> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception("Failed to get ID token");
    }
    return token;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ----------------------------------
  // 👥 LIST FRIENDS
  // GET /friends
  // ----------------------------------
  static Future<List<String>> listFriends() async {
    final uri = Uri.https(_baseUrl, "/friends");

    final response =
        await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch friends");
    }

    final decoded = json.decode(response.body);
    return List<String>.from(decoded["friends"]);
  }

  // ----------------------------------
  // 📩 SEND FRIEND REQUEST
  // POST /friends/request?target_uid=
  // ----------------------------------
  static Future<void> sendFriendRequest(String targetUid) async {
    final uri = Uri.https(
      _baseUrl,
      "/friends/request",
      {"target_uid": targetUid},
    );

    final response =
        await http.post(uri, headers: await _headers());

    if (response.statusCode != 200) {
      final msg = json.decode(response.body)["detail"];
      throw Exception(msg);
    }
  }

  // ----------------------------------
  // ✅ ACCEPT FRIEND REQUEST
  // POST /friends/accept?target_uid=
  // ----------------------------------
  static Future<String> acceptFriendRequest(String targetUid) async {
    final uri = Uri.https(
      _baseUrl,
      "/friends/accept",
      {"target_uid": targetUid},
    );

    final response =
        await http.post(uri, headers: await _headers());

    if (response.statusCode != 200) {
      final msg = json.decode(response.body)["detail"];
      throw Exception(msg);
    }

    final decoded = json.decode(response.body);
    return decoded["chatRoomID"];
  }

  // ----------------------------------
  // ⏳ GET PENDING REQUESTS
  // GET /friends/pending
  // ----------------------------------
  static Future<List<FriendRequestModel>> getPendingRequests() async {
    final uri = Uri.https(_baseUrl, "/friends/pending");

    final response =
        await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch pending requests");
    }

    final decoded = json.decode(response.body);

    return (decoded["pending_requests"] as List)
        .map((e) => FriendRequestModel.fromJson(e))
        .toList();
  }
}
