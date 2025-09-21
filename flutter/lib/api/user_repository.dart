import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

Future<User> getUserById(String userId) async {
  var url = Uri.parse(
    'https://9bqx1rzgv3.execute-api.us-east-1.amazonaws.com/default/Get_User_By_Id',
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
      final user = User.fromJSON(decoded[0]);
      debugPrint("User likes (raw): ${user.likes.map((v) => v.id).toList()}");
      return User.fromJSON(decoded[0]);
    } else if (decoded is Map<String, dynamic>) {
      // nel caso ritorni un singolo oggetto
      final user = User.fromJSON(decoded);
      debugPrint("User likes (raw): ${user.likes.map((v) => v.id).toList()}");
      return User.fromJSON(decoded);
    } else {
      throw Exception('Unexpected API response format');
    }
  } else {
    throw Exception('Failed to load user');
  }
}

// import 'dart:async';
// import 'dart:convert';
// import '../models/user.dart';

// Future<User> getUserById(String userId) async {
//   // Simuliamo un ritardo come se fosse una chiamata API
//   await Future.delayed(const Duration(seconds: 1));

//   // Risposta mock (in un caso reale prenderesti una pagina diversa a seconda di `page`)
//   const mockResponse = '''
//   {
//     "user_id": "39",
//     "first_name": "Charlie",
//     "last_name": "Wilson",
//     "username": "charliewilson921",
//     "likes": [
//       {
//         "_id": "526880",
//         "slug": "george_zaidan_how_do_gas_masks_actually_work",
//         "title": "How do gas masks actually work?",
//         "url": "https://www.ted.com/talks/george_zaidan_how_do_gas_masks_actually_work",
//         "description": "You might think of gas masks as clunky military-looking devices...",
//         "duration": "254",
//         "publishedAt": "2024-04-30T15:14:51Z",
//         "presenterDisplayName": "George Zaidan",
//         "tags": [
//           "environment",
//           "technology",
//           "design",
//           "education",
//           "natural disaster",
//           "chemistry",
//           "TED-Ed",
//           "animation"
//         ],
//         "thumbnails": [
//           {
//             "slug": "george_zaidan_how_do_gas_masks_actually_work",
//             "url": "https://talkstar-assets.s3.amazonaws.com/production/talks/talk_128547/250158f0-4687-41d3-abbe-df39232ee19a/gasmaskstextless.jpg"
//           }
//         ],
//         "watch_next": [
//           {
//             "_id": "109914",
//             "slug": "stephanie_honchell_smith_whatever_happened_to_the_hole_in_the_ozone_layer",
//             "title": "Whatever happened to the hole in the ozone layer?",
//             "duration": "293",
//             "viewedCount": "552783",
//             "presenterDisplayName": "Stephanie Honchell Smith"
//           }
//         ]
//       },
//       {
//         "_id": "526880",
//         "slug": "george_zaidan_how_do_gas_masks_actually_work",
//         "title": "How do gas masks actually work?",
//         "url": "https://www.ted.com/talks/george_zaidan_how_do_gas_masks_actually_work",
//         "description": "You might think of gas masks as clunky military-looking devices...",
//         "duration": "254",
//         "publishedAt": "2024-04-30T15:14:51Z",
//         "presenterDisplayName": "George Zaidan",
//         "tags": [
//           "environment",
//           "technology",
//           "design",
//           "education",
//           "natural disaster",
//           "chemistry",
//           "TED-Ed",
//           "animation"
//         ],
//         "thumbnails": [
//           {
//             "slug": "george_zaidan_how_do_gas_masks_actually_work",
//             "url": "https://talkstar-assets.s3.amazonaws.com/production/talks/talk_128547/250158f0-4687-41d3-abbe-df39232ee19a/gasmaskstextless.jpg"
//           }
//         ],
//         "watch_next": [
//           {
//             "_id": "109914",
//             "slug": "stephanie_honchell_smith_whatever_happened_to_the_hole_in_the_ozone_layer",
//             "title": "Whatever happened to the hole in the ozone layer?",
//             "duration": "293",
//             "viewedCount": "552783",
//             "presenterDisplayName": "Stephanie Honchell Smith"
//           }
//         ]
//       }
//     ]
//   }
//   ''';

//   final decoded = json.decode(mockResponse);
//   return User.fromJSON(decoded);
// }
