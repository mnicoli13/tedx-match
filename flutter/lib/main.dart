import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/find_match_page.dart';
import '../pages/likes_page.dart';
import 'models/user.dart';
import 'api/match_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDx Match',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  User? _selectedUser; // utente scelto in homepage
  List<User> _likedUsers = [];
  bool _loadingLikes = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _fetchLikedUsers();
    }
  }

  Future<void> _fetchLikedUsers() async {
    if (_selectedUser == null) return;

    setState(() => _loadingLikes = true);

    try {
      // qui passiamo l’array di user_id che l’utente ha messo like
      // immagino che tu lo abbia salvato in _selectedUser.likesPeople
      final likedUsers = await getLikesByUserIds(_selectedUser!.likesPeople);

      setState(() {
        _likedUsers = likedUsers;
      });
    } catch (e) {
      debugPrint("Errore caricamento liked users: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore caricamento likes: $e")));
    } finally {
      setState(() => _loadingLikes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onUserSelected: (user) {
          setState(() {
            _selectedUser = user;
            _selectedIndex = 1; // vai subito al profilo
          });
        },
      ),
      MatchPage(
        currentUserId: _selectedUser?.userId ?? "1",
        tags: _selectedUser?.likes.expand((l) => l.tags).toList() ?? [],
      ),
      LikesPage(likedUsers: _likedUsers, isLoading: _loadingLikes),
      ProfilePage(user: _selectedUser),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Match"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Likes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profilo"),
        ],
      ),
    );
  }
}
