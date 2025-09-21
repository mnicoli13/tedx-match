class Video {
  final String id;
  final String slug;
  final String title;
  final String url;
  final String description;
  final String duration;
  final String publishedAt;
  final String presenterDisplayName;
  final List<String> tags;
  final List<String> thumbnails;

  Video({
    required this.id,
    required this.slug,
    required this.title,
    required this.url,
    required this.description,
    required this.duration,
    required this.publishedAt,
    required this.presenterDisplayName,
    required this.tags,
    required this.thumbnails,
  });

  factory Video.fromJSON(Map<String, dynamic> json) {
    return Video(
      id: json['_id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      presenterDisplayName: json['presenterDisplayName'] ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((t) => t.toString())
          .toList(),
      thumbnails: (json['thumbnails'] as List<dynamic>? ?? [])
          .map((thumb) => thumb['url'].toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'url': url,
      'description': description,
    };
  }
}
