import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/match_repository.dart';
import './video_detail_page.dart';
import './tag_detail_page.dart';

import 'dart:developer';

class MatchPage extends StatefulWidget {
  final String currentUserId;
  final List<String> tags;

  const MatchPage({Key? key, required this.currentUserId, required this.tags})
    : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  User? _currentMatch;
  bool _loading = true;
  int _page = 0; // 🔑 aggiunto per la paginazione

  @override
  void initState() {
    super.initState();
    _loadNextUser();
  }

  Future<void> _loadNextUser() async {
    setState(() {
      _loading = true;
    });
    try {
      final user = await findMatchesByTags(
        widget.currentUserId,
        widget.tags,
        _page,
      );

      setState(() {
        _currentMatch = user;
        _page++; // 🔑 aumenta la pagina ogni volta che carichi un nuovo utente
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore: $e")));
      setState(() {
        _currentMatch = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onLike() async {
    if (_currentMatch == null) return;

    debugPrint("Hai messo like a ${_currentMatch!.username}");

    try {
      await addLikeToUser(
        widget.currentUserId,
        _currentMatch!.userId.toString(),
      );
      debugPrint("Like registrato su server");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore nel like: $e")));
    }

    _loadNextUser();
  }

  void _onSkip() {
    debugPrint("Hai skippato ${_currentMatch?.username}");
    _loadNextUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentMatch == null
          ? const Center(child: Text("Nessun utente trovato"))
          : Stack(
              children: [
                // Immagine a tutto schermo
                Positioned.fill(
                  child:
                      _currentMatch!.thumbnail != null &&
                          _currentMatch!.thumbnail!.isNotEmpty
                      ? Image.network(
                          _currentMatch!.thumbnail!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[300]),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.25, // parte visibile inizialmente
                  minChildSize: 0.25, // quanto resta visibile al minimo
                  maxChildSize: 0.6, // espansione massima
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Barra di "drag" visiva
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                            // Riga con nome e pulsanti
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Info utente
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_currentMatch!.firstName} ${_currentMatch!.lastName}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "@${_currentMatch!.username}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                // Pulsanti stile Tinder
                                Row(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: "skip",
                                      mini: true,
                                      onPressed: _onSkip,
                                      backgroundColor: Colors.white,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    FloatingActionButton(
                                      heroTag: "like",
                                      mini: true,
                                      onPressed: _onLike,
                                      backgroundColor: Colors.white,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.green,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Tag
                            Wrap(
                              spacing: 6,
                              children: _currentMatch!.likes
                                  .expand((like) => like.tags)
                                  .take(5)
                                  .map(
                                    (tag) => ActionChip(
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
                                  )
                                  .toList(),
                            ),

                            if (_currentMatch!.likes.isNotEmpty) ...[
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _currentMatch!.likes.length,
                                itemBuilder: (context, index) {
                                  final like = _currentMatch!.likes[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: like.thumbnails.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.network(
                                                      like.thumbnails.first,
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.video_library,
                                                    size: 40,
                                                  ),
                                            title: Text(
                                              like.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              like.presenterDisplayName,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VideoDetailPage(
                                                        video: like,
                                                      ),
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
                                                padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                ),
                                                child: Row(
                                                  children: like.tags.map((
                                                    tag,
                                                  ) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 6,
                                                          ),
                                                      child: ActionChip(
                                                        label: Text(tag),
                                                        backgroundColor:
                                                            Colors.red[200],
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  TagDetailPage(
                                                                    tag: tag,
                                                                  ),
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
                  },
                ),
              ],
            ),
    );
  }
}
