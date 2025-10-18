import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewStoriesPage extends StatefulWidget {
  const NewStoriesPage({super.key});

  @override
  State<NewStoriesPage> createState() => _NewStoriesPageState();
}

class _NewStoriesPageState extends State<NewStoriesPage> {
  late Future<List<int>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = fetchNewStories();
  }

  Future<List<int>> fetchNewStories() async {
    final url = Uri.parse(
      'https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<int>();
    }
    throw Exception('Failed to load new stories');
  }

  Future<Map<String, dynamic>> fetchItem(int id) async {
    final url = Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$id.json?print=pretty',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    }
    throw Exception('Failed to load item $id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    'New Stories',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF134686),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<int>>(
              future: _storiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final stories = snapshot.data ?? <int>[];
                if (stories.isEmpty) {
                  return const Center(child: Text('No stories found'));
                }
                final visible = stories.length > 50
                    ? stories.sublist(0, 50)
                    : stories;
                return ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final id = visible[index];
                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchItem(id),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: const Text('Loading...'),
                          );
                        }
                        if (snap.hasError) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text('Error: ${snap.error}'),
                          );
                        }
                        final item = snap.data ?? <String, dynamic>{};
                        final title = item['title'] ?? 'No title';
                        final by = item['by'] ?? '';
                        final score = item['score']?.toString() ?? '';
                        final link = item['url'];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(title),
                            subtitle: Text('by $by • $score pts'),
                            trailing: link != null
                                ? IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () async {
                                      final uri = Uri.parse(link as String);
                                      await launchUrl(uri);
                                    },
                                  )
                                : null,
                            onTap: link != null
                                ? () async {
                                    final uri = Uri.parse(link as String);
                                    await launchUrl(uri);
                                  }
                                : null,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
