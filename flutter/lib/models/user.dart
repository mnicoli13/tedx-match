import 'video.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String thumbnail;
  final List<Video> likes;
  final List<String> likesPeople;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.thumbnail,
    required this.likes,
    required this.likesPeople,
  });

  factory User.fromJSON(Map<String, dynamic> jsonMap) {
    return User(
      userId: jsonMap['user_id'] ?? '',
      firstName: jsonMap['first_name'] ?? '',
      lastName: jsonMap['last_name'] ?? '',
      username: jsonMap['username'] ?? '',
      thumbnail: jsonMap['thumbnail'] ?? '',
      likes: (jsonMap['likes'] as List<dynamic>? ?? [])
          .map((like) => Video.fromJSON(like as Map<String, dynamic>))
          .toList(),
      likesPeople: (jsonMap['likes_people'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'thumbnail': thumbnail,
      'likes': likes.map((video) => video.toJson()).toList(),
      'likes_people': likesPeople,
    };
  }

  @override
  String toString() {
    return 'User(userId: $userId, firstName: $firstName, lastName: $lastName, username: $username, thumbnail: $thumbnail, likes: ${likes.length} video(s), likesPeople: $likesPeople)';
  }
}
