import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollama/ollama.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const Color _primaryColor = Color(0xFF134686);

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final Ollama ollama;
  static const _prefsKey = 'chat_history_v1';

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Default host override for physical device testing (your machine LAN IP).
    // Change this if your host IP changes.
    const String hostOverride = 'http://192.168.0.232:11434';

    // Use the override when provided; otherwise pick emulator mapping or localhost.
    final host = hostOverride.isNotEmpty
        ? hostOverride
        : ((!kIsWeb && Platform.isAndroid)
              ? 'http://10.0.2.2:11434' // Android emulator -> host localhost
              : 'http://127.0.0.1:11434'); // desktop/web

    // Initialize Ollama client
    ollama = Ollama(baseUrl: Uri.parse(host));

    // Load persisted chat history
    _loadHistory();
    // Update UI when input text changes so the send button state refreshes
    _controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_prefsKey) ?? [];
      // Stored as alternating role|content entries
      final List<_ChatMessage> loaded = [];
      for (var i = 0; i + 1 < stored.length; i += 2) {
        final role = stored[i];
        final content = stored[i + 1];
        loaded.add(_ChatMessage(text: content, isUser: role == 'user'));
      }
      if (loaded.isNotEmpty) {
        setState(() {
          _messages.addAll(loaded);
        });
      }
    } catch (e) {
      // ignore errors loading prefs
      // ignore: avoid_print
      print('Failed to load chat history: $e');
    }
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // keep last 10 messages
      final recent = _messages.length <= 10
          ? _messages
          : _messages.sublist(_messages.length - 10);
      final List<String> toStore = [];
      for (final m in recent) {
        toStore.add(m.isUser ? 'user' : 'assistant');
        toStore.add(m.text);
      }
      await prefs.setStringList(_prefsKey, toStore);
    } catch (e) {
      // ignore
      // ignore: avoid_print
      print('Failed to persist history: $e');
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      // Add a placeholder bot message that we'll update as chunks arrive
      _messages.add(_ChatMessage(text: '', isUser: false));
      _isSending = true;
    });

    _controller.clear();

    // Keep a reference to the index of the bot message we will update
    final botIndex = _messages.length - 1;

    // Scroll to bottom (reversed list)
    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    try {
      // Build the messages for the API
      // Include recent history as context (last 10 messages)
      final history = _messages.length <= 10
          ? _messages
          : _messages.sublist(_messages.length - 10);
      final messages = [
        for (final m in history)
          ChatMessage(role: m.isUser ? 'user' : 'assistant', content: m.text),
        ChatMessage(role: 'user', content: text),
      ];

      // Make sure the ollama client is available (initialized in initState)
      final stream = ollama.chat(messages, model: 'qwen3:0.6b');

      await for (final chunk in stream) {
        final content = chunk.message?.content;
        if (content == null) continue;

        setState(() {
          // Append the incoming chunk to the bot message text
          final prev = _messages[botIndex];
          _messages[botIndex] = _ChatMessage(
            text: prev.text + content,
            isUser: false,
          );
        });

        scrollToBottom();
      }
      // Persist history after successful completion
      await _persistHistory();
    } catch (e, st) {
      // Replace the bot message with an error message
      setState(() {
        _messages[botIndex] = _ChatMessage(text: 'Error: $e', isUser: false);
      });
      // ignore: avoid_print
      print('Error streaming reply: $e\n$st');
    } finally {
      setState(() {
        _isSending = false;
      });
      scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: Text(
          'OLLAMA chatbot',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Start the conversation',
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        // Because list is reversed, show from the end
                        final msg = _messages[_messages.length - 1 - index];
                        return _buildMessageBubble(msg);
                      },
                    ),
            ),
            const Divider(height: 1),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final bg = msg.isUser ? _primaryColor : Colors.grey.shade200;
    final align = msg.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textColor = msg.isUser ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: msg.isUser
                ? Text(msg.text, style: GoogleFonts.inter(color: textColor))
                : _buildMarkdownWithThinking(msg.text, textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownWithThinking(String text, Color textColor) {
    // Split into segments of normal markdown and <think>thinking</think>
    int idx = 0;
    while (idx < text.length) {
      final open = text.indexOf('<think>', idx);
      if (open == -1) {
        final md = text.substring(idx);
        if (md.isNotEmpty) {
          return MarkdownBody(
            data: md,
            styleSheet: MarkdownStyleSheet.fromTheme(
              Theme.of(context),
            ).copyWith(p: GoogleFonts.inter(color: textColor)),
          );
        }
        break;
      }

      if (open > idx) {
        final md = text.substring(idx, open);
        // Render the markdown segment
        return MarkdownBody(
          data: md,
          styleSheet: MarkdownStyleSheet.fromTheme(
            Theme.of(context),
          ).copyWith(p: GoogleFonts.inter(color: textColor)),
        );
      }

      final close = text.indexOf('</think>', open + 7);
      if (close == -1) {
        final thinking = text.substring(open + 7);
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: thinking,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      } else {
        final thinking = text.substring(open + 7, close);
        // Render thinking seg as grey text and continue with remainder by recursion
        final remainder = text.substring(close + 8);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: thinking,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _buildMarkdownWithThinking(remainder, textColor),
          ],
        );
      }
    }

    // fallback
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(
        Theme.of(context),
      ).copyWith(p: GoogleFonts.inter(color: textColor)),
    );
  }

  // _buildSpansForMessage removed in favor of Markdown rendering with
  // _buildMarkdownWithThinking above.

  Widget _buildInputArea() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 6,
              // allow Enter to insert new lines; sending is done with the send button
              onSubmitted: null,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: _primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: (_isSending || _controller.text.trim().isEmpty)
                  ? null
                  : _send,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
