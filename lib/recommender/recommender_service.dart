import 'dart:convert';

import 'package:http/http.dart' as http;

class RecommenderService {
  static Future<List<Map<String, dynamic>>> getRecommendations(
      String userId) async {
    final uri = Uri.https(
      "travelr-ml.onrender.com",
      "/recommend/$userId",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to fetch recommendations: ${response.statusCode}: ${response.body}",
      );
    }

    final decoded = json.decode(response.body);

    if (decoded is! Map || decoded["recommendations"] is! List) {
      throw Exception("Invalid recommendations response format");
    }

    return List<Map<String, dynamic>>.from(decoded["recommendations"]);
  }
}
