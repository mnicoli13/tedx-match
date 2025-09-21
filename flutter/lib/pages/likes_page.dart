import 'package:flutter/material.dart';
import '../models/user.dart';
import './profile_page.dart';
import './tag_detail_page.dart';

class LikesPage extends StatelessWidget {
  final List<User> likedUsers;
  final bool isLoading;

  const LikesPage({Key? key, required this.likedUsers, required this.isLoading})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferiti")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedUsers.isEmpty
          ? const Center(child: Text("Non hai ancora messo like a nessuno"))
          : ListView.builder(
              itemCount: likedUsers.length,
              itemBuilder: (context, index) {
                final user = likedUsers[index];

                debugPrint(
                  "LikesPage - Utente: ${user.username}, "
                  "Nome: ${user.firstName} ${user.lastName}, "
                  "Thumbnail: ${user.thumbnail}",
                );

                // 🔑 Raccolgo i tag da tutti i like dell'utente
                final userTags = user.likes
                    .expand((like) => like.tags)
                    .toSet()
                    .toList();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: user.thumbnail.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.thumbnail),
                                )
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text("${user.firstName} ${user.lastName}"),
                          subtitle: Text("@${user.username}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfilePage(user: user),
                              ),
                            );
                          },
                        ),

                        // 👇 Tag scrollabili se esistono
                        if (userTags.isNotEmpty) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                children: userTags.map((tag) {
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
    );
  }
}
