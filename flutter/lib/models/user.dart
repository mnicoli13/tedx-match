import 'video.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final List<Video> likes;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.likes,
  });

  factory User.fromJSON(Map<String, dynamic> jsonMap) {
    return User(
      userId: jsonMap['user_id'] ?? '',
      firstName: jsonMap['first_name'] ?? '',
      lastName: jsonMap['last_name'] ?? '',
      username: jsonMap['username'] ?? '',
      likes: (jsonMap['likes'] as List<dynamic>? ?? [])
          .map((like) => Video.fromJSON(like as Map<String, dynamic>))
          .toList(),
    );
  }
}
