import 'package:flutter/material.dart';
import '../models/user.dart';

class HomePage extends StatelessWidget {
  final Function(User) onUserSelected;

  const HomePage({super.key, required this.onUserSelected});

  @override
  Widget build(BuildContext context) {
    // lista mock di utenti per test
    final users = [
      User(
        userId: "1",
        firstName: "Mario",
        lastName: "Rossi",
        username: "mrossi",
        likes: [],
      ),
      User(
        userId: "2",
        firstName: "Giulia",
        lastName: "Bianchi",
        username: "gbianchi",
        likes: [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Homepage")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            title: Text("${u.firstName} ${u.lastName}"),
            subtitle: Text(u.username),
            onTap: () => onUserSelected(u),
          );
        },
      ),
    );
  }
}
