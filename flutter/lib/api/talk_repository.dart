import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/talk.dart';
import '../models/video.dart';

Future<List<Talk>> initEmptyList() async {
  Iterable list = json.decode("[]");
  var talks = list.map((model) => Talk.fromJSON(model)).toList();
  return talks;
}

Future<List<Video>> getTalksByTag(String tag, int page) async {
  var url = Uri.parse(
    'https://2qxeauck4a.execute-api.us-east-1.amazonaws.com/default/Get_Talk_By_Tag',
  );

  final http.Response response = await http.post(
    url,
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, Object>{
      'tag': tag,
      'page': page,
      'doc_per_page': 5,
    }),
  );
  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((json) => Video.fromJSON(json)).toList();
  } else {
    throw Exception('Failed to load talks');
  }
}

Future<List<Video>> getWatchNextById(String id) async {
  var url = Uri.parse(
    'https://5paxmly8u8.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next_by_Idx',
  );

  final http.Response response = await http.post(
    url,
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, Object>{'id': id}),
  );
  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((json) => Video.fromJSON(json)).toList();
  } else {
    throw Exception('Failed to load talks');
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:mytedx/models/video.dart';
// import '../models/talk.dart';

// Future<List<Talk>> getTalksByTag(String tag, int page) async {
//   // Simuliamo un ritardo come se fosse una vera chiamata HTTP
//   await Future.delayed(const Duration(seconds: 1));

//   // Risposta mock (puoi sostituire con più pagine se vuoi simulare la paginazione)
//   const mockResponse = '''
// [
//   {
//     "_id": "526880",
//     "slug": "george_zaidan_how_do_gas_masks_actually_work",
//     "title": "How do gas masks actually work?",
//     "url": "https://www.ted.com/talks/george_zaidan_how_do_gas_masks_actually_work",
//     "description": "You might think of gas masks as clunky military-looking devices. But in the near future, we may need to rely on these filters as part of our everyday lives.",
//     "duration": "254",
//     "publishedAt": "2024-04-30T15:14:51Z",
//     "presenterDisplayName": "George Zaidan",
//     "tags": [
//       "environment",
//       "technology",
//       "design",
//       "education",
//       "natural disaster",
//       "chemistry",
//       "TED-Ed",
//       "animation"
//     ],
//     "thumbnails": [
//       {
//         "slug": "george_zaidan_how_do_gas_masks_actually_work",
//         "url": "https://talkstar-assets.s3.amazonaws.com/production/talks/talk_128547/250158f0-4687-41d3-abbe-df39232ee19a/gasmaskstextless.jpg"
//       }
//     ],
//     "watch_next": [
//       {
//         "_id": "109914",
//         "slug": "stephanie_honchell_smith_whatever_happened_to_the_hole_in_the_ozone_layer",
//         "title": "Whatever happened to the hole in the ozone layer?",
//         "duration": "293",
//         "viewedCount": "552783",
//         "presenterDisplayName": "Stephanie Honchell Smith"
//       }
//     ]
//   },
//   {
//     "_id": "528289",
//     "slug": "pete_stavros_the_secret_ingredient_of_business_success",
//     "title": "The secret ingredient of business success",
//     "url": "https://www.ted.com/talks/pete_stavros_the_secret_ingredient_of_business_success",
//     "description": "Too often, employees are unmotivated and unhappy, with no real incentive to invest much of anything into their place of work.",
//     "duration": "786",
//     "publishedAt": "2024-04-26T14:47:51Z",
//     "presenterDisplayName": "Pete Stavros",
//     "tags": ["business","social change","leadership","finance","investing"],
//     "thumbnails": [
//       {
//         "slug": "pete_stavros_the_secret_ingredient_of_business_success",
//         "url": "https://talkstar-photos.s3.amazonaws.com/uploads/e23151ce-670d-4c60-8e52-5feb62403d3f/PeteStavros_2024-embed.jpg"
//       }
//     ],
//     "watch_next": [
//       {
//         "_id": "127050",
//         "slug": "amber_cabral_3_steps_to_better_connect_with_your_fellow_humans",
//         "title": "3 steps to better connect with your fellow humans",
//         "duration": "769",
//         "viewedCount": "511871",
//         "presenterDisplayName": "Amber Cabral"
//       }
//     ]
//   }
// ]
// ''';

//   final List<dynamic> jsonList = json.decode(mockResponse);
//   return jsonList.map((json) => Talk.fromJSON(json)).toList();
// }

// Future<List<Video>> getWatchNextById(String id) async {
//   // Simuliamo un ritardo come se fosse una vera chiamata HTTP
//   await Future.delayed(const Duration(seconds: 1));

//   // Risposta mock (puoi sostituire con più pagine se vuoi simulare la paginazione)
//   const mockResponse = '''
// [
//   {
//     "_id": "526880",
//     "slug": "george_zaidan_how_do_gas_masks_actually_work",
//     "title": "How do gas masks actually work?",
//     "url": "https://www.ted.com/talks/george_zaidan_how_do_gas_masks_actually_work",
//     "description": "You might think of gas masks as clunky military-looking devices. But in the near future, we may need to rely on these filters as part of our everyday lives.",
//     "duration": "254",
//     "publishedAt": "2024-04-30T15:14:51Z",
//     "presenterDisplayName": "George Zaidan",
//     "tags": [
//       "environment",
//       "technology",
//       "design",
//       "education",
//       "natural disaster",
//       "chemistry",
//       "TED-Ed",
//       "animation"
//     ],
//     "thumbnails": [
//       {
//         "slug": "george_zaidan_how_do_gas_masks_actually_work",
//         "url": "https://talkstar-assets.s3.amazonaws.com/production/talks/talk_128547/250158f0-4687-41d3-abbe-df39232ee19a/gasmaskstextless.jpg"
//       }
//     ],
//     "watch_next": [
//       {
//         "_id": "109914",
//         "slug": "stephanie_honchell_smith_whatever_happened_to_the_hole_in_the_ozone_layer",
//         "title": "Whatever happened to the hole in the ozone layer?",
//         "duration": "293",
//         "viewedCount": "552783",
//         "presenterDisplayName": "Stephanie Honchell Smith"
//       }
//     ]
//   },
//   {
//     "_id": "528289",
//     "slug": "pete_stavros_the_secret_ingredient_of_business_success",
//     "title": "The secret ingredient of business success",
//     "url": "https://www.ted.com/talks/pete_stavros_the_secret_ingredient_of_business_success",
//     "description": "Too often, employees are unmotivated and unhappy, with no real incentive to invest much of anything into their place of work.",
//     "duration": "786",
//     "publishedAt": "2024-04-26T14:47:51Z",
//     "presenterDisplayName": "Pete Stavros",
//     "tags": ["business","social change","leadership","finance","investing"],
//     "thumbnails": [
//       {
//         "slug": "pete_stavros_the_secret_ingredient_of_business_success",
//         "url": "https://talkstar-photos.s3.amazonaws.com/uploads/e23151ce-670d-4c60-8e52-5feb62403d3f/PeteStavros_2024-embed.jpg"
//       }
//     ],
//     "watch_next": [
//       {
//         "_id": "127050",
//         "slug": "amber_cabral_3_steps_to_better_connect_with_your_fellow_humans",
//         "title": "3 steps to better connect with your fellow humans",
//         "duration": "769",
//         "viewedCount": "511871",
//         "presenterDisplayName": "Amber Cabral"
//       }
//     ]
//   }
// ]
// ''';

//   final List<dynamic> jsonList = json.decode(mockResponse);
//   return jsonList.map((json) => Video.fromJSON(json)).toList();
// }
