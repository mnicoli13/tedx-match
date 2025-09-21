import 'package:flutter/material.dart';
import '../models/user.dart';
import './video_detail_page.dart';
import './tag_detail_page.dart';

class ProfilePage extends StatelessWidget {
  final User? user;

  const ProfilePage({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Nessun utente selezionato")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profilo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 Foto profilo
            CircleAvatar(
              radius: 60,
              backgroundImage: user!.thumbnail.isNotEmpty
                  ? NetworkImage(user!.thumbnail)
                  : null,
              child: user!.thumbnail.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 16),

            // ℹ️ Info principali in una Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user!.firstName} ${user!.lastName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "@${user!.username}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ❤️ Sezione dei liked talks
            if (user!.likes.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Liked Talks",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: user!.likes.length,
                itemBuilder: (context, index) {
                  final like = user!.likes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: like.thumbnails.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      like.thumbnails.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.video_library, size: 40),
                            title: Text(
                              like.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(like.presenterDisplayName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoDetailPage(video: like),
                                ),
                              );
                            },
                          ),
                          if (like.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            // 👇 Scroll orizzontale dei tag con stile "MatchPage"
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  children: like.tags.map((tag) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ActionChip(
                                        label: Text(tag),
                                        backgroundColor: Colors.red[200],
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TagDetailPage(tag: tag),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
