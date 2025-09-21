import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/user_repository.dart';

class HomePage extends StatefulWidget {
  final Function(User) onUserSelected;

  const HomePage({super.key, required this.onUserSelected});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _userController = TextEditingController();

  void _getUser() async {
    try {
      final user = await getUserById(_userController.text);
      widget.onUserSelected(user);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Homepage")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                hintText: 'Enter your User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _getUser, child: const Text('Load User')),
          ],
        ),
      ),
    );
  }
}
