import 'package:flutter/material.dart';
import '../models/user.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, ${user!.firstName} ${user!.lastName}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text("Username: ${user!.username}"),
          const SizedBox(height: 8),
          if (user!.likes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "Liked Talks:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: user!.likes.length,
                itemBuilder: (context, index) {
                  final like = user!.likes[index];
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
                      onTap: () => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(like.description))),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
