import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

Future<User> getUserById(String userId) async {
  var url = Uri.parse(
    'https://1yegowwc80.execute-api.us-east-1.amazonaws.com/default/Get_User_By_Id',
  );

  final http.Response response = await http.post(
    url,
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, Object>{'user_id': userId}),
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final dynamic decoded = json.decode(body);

    if (decoded is List && decoded.isNotEmpty) {
      // prendi il primo utente dalla lista
      return User.fromJSON(decoded[0]);
    } else if (decoded is Map<String, dynamic>) {
      // nel caso ritorni un singolo oggetto
      return User.fromJSON(decoded);
    } else {
      throw Exception('Unexpected API response format');
    }
  } else {
    throw Exception('Failed to load user');
  }
}
