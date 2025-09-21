import 'package:flutter/material.dart';
import '../models/video.dart';
import '../api/talk_repository.dart';
import 'video_detail_page.dart';

class TagDetailPage extends StatefulWidget {
  final String tag;

  const TagDetailPage({Key? key, required this.tag}) : super(key: key);

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  final List<Video> _videos = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newVideos = await getTalksByTag(widget.tag, _currentPage);

      setState(() {
        _currentPage++;
        _videos.addAll(newVideos);
        if (newVideos.length < 10) {
          _hasMore = false; // non ci sono altre pagine
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore caricamento: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tag: ${widget.tag}")),
      body: _videos.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final video = _videos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        child: ListTile(
                          leading: video.thumbnails.isNotEmpty
                              ? Image.network(
                                  video.thumbnails.first,
                                  width: 60,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          title: Text(video.title),
                          subtitle: Text(video.presenterDisplayName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoDetailPage(video: video),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Se ci sono altre pagine → mostra pulsante
                if (_hasMore)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _fetchVideos,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Carica altri"),
                    ),
                  ),
              ],
            ),
    );
  }
}
