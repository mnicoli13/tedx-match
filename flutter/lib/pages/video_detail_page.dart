import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/talk_repository.dart';
import '../models/video.dart';
import './tag_detail_page.dart';

class VideoDetailPage extends StatelessWidget {
  final Video video;

  const VideoDetailPage({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail o player
            if (video.thumbnails.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  video.thumbnails.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

            const SizedBox(height: 16),

            Text(
              video.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(
              "By ${video.presenterDisplayName}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Text(video.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.timer, size: 18),
                const SizedBox(width: 6),
                Text("Durata: ${video.duration} min"),
              ],
            ),

            const SizedBox(width: 20),

            Row(
              children: [
                const Icon(Icons.date_range, size: 18),
                const SizedBox(width: 6),
                Text("Pubblicato: ${video.publishedAt}"),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Guarda video"),
              onPressed: () async {
                final uri = Uri.parse(video.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Impossibile aprire il video"),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Tags",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 6,
              children: video.tags.map((tag) {
                return ActionChip(
                  label: Text(tag),
                  backgroundColor: Colors.red[200],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagDetailPage(tag: tag),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            const Text(
              "Watch Next",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            FutureBuilder<List<Video>>(
              future: getWatchNextById(video.id), // API call
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Errore: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Nessun video disponibile");
                }

                final watchNext = snapshot.data!;
                return Column(
                  children: watchNext.map((like) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(like.title),
                        subtitle: Text(like.presenterDisplayName),
                        leading: like.thumbnails.isNotEmpty
                            ? Image.network(
                                like.thumbnails.first,
                                width: 60,
                                fit: BoxFit.cover,
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoDetailPage(video: like),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
