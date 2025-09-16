import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

Future<List<User>> findMatchesByTags(String userId, List<String> tags) async {
  var url = Uri.parse(
    'https://brz4v3vbi3.execute-api.us-east-1.amazonaws.com/default/Find_similar_user',
  );

  final http.Response response = await http.post(
    url,
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, Object>{'user_id': userId, 'video_tags': tags}),
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final dynamic decoded = json.decode(body);

    if (decoded is List && decoded.isNotEmpty) {
      // mappa ogni elemento della lista in un oggetto User
      return decoded.map<User>((json) => User.fromJSON(json)).toList();
    } else {
      throw Exception('No matching users found or unexpected response format');
    }
  } else {
    throw Exception('Failed to load users');
  }
}
