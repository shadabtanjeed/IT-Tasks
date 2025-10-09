import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollama/ollama.dart' as ollama;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/chat_session.dart';
import '../services/chat_session_manager.dart';

const Color _primaryColor = Color(0xFF134686);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatSessionManager _sessionManager = ChatSessionManager();

  late final ollama.Ollama ollamaClient;

  List<ChatSession> _allSessions = [];
  ChatSession? _currentSession;
  bool _isSending = false;
  bool _isLoading = true;
  // If true, show <think>...</think> contents; if false, those parts are removed
  bool enableThinking = false;

  @override
  void initState() {
    super.initState();
    _initializeOllama();
    _controller.addListener(_onInputChanged);
    _loadOrCreateSession();
  }

  void _initializeOllama() {
    const String hostOverride = 'http://192.168.0.232:11434';
    final host = hostOverride.isNotEmpty
        ? hostOverride
        : ((!kIsWeb && Platform.isAndroid)
              ? 'http://10.0.2.2:11434'
              : 'http://127.0.0.1:11434');
    ollamaClient = ollama.Ollama(baseUrl: Uri.parse(host));
  }

  Future<void> _loadOrCreateSession() async {
    setState(() => _isLoading = true);

    // Always create a fresh chat session on app startup.
    _allSessions = await _sessionManager.loadSessions();
    _currentSession = await _sessionManager.createNewSession(_allSessions);
    _allSessions = await _sessionManager.loadSessions();

    setState(() => _isLoading = false);
  }

  String _generateTitleFromMessage(String message) {
    // Normalize whitespace
    final cleaned = message.replaceAll(RegExp(r"\s+"), ' ').trim();
    if (cleaned.isEmpty) {
      final idx = _allSessions.length + 1;
      return 'Chat $idx';
    }

    // Remove common punctuation but keep word characters and spaces
    final stripped = cleaned.replaceAll(RegExp(r"[^\w\s]"), '');
    final words = stripped.split(' ').where((w) => w.isNotEmpty).toList();
    final take = words.take(5).toList();
    var title = take.join(' ').trim();
    if (title.isEmpty) {
      final idx = _allSessions.length + 1;
      return 'Chat $idx';
    }
    if (title.length > 40) title = '${title.substring(0, 37).trim()}...';
    return title[0].toUpperCase() + title.substring(1);
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _createNewChat() async {
    final newSession = await _sessionManager.createNewSession(_allSessions);
    _allSessions = await _sessionManager.loadSessions();
    setState(() {
      _currentSession = newSession;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  Future<void> _switchToSession(ChatSession session) async {
    await _sessionManager.setCurrentSessionId(session.id);
    setState(() {
      _currentSession = session;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  Future<void> _deleteSession(ChatSession session) async {
    if (_allSessions.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the last chat')),
      );
      return;
    }

    await _sessionManager.deleteSession(session.id, _allSessions);
    _allSessions = await _sessionManager.loadSessions();

    if (_currentSession?.id == session.id) {
      _currentSession = _allSessions.last;
      await _sessionManager.setCurrentSessionId(_currentSession!.id);
    }

    setState(() {});
  }

  Future<void> _send() async {
    if (_currentSession == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    // Remember whether this session had any messages before this send.
    final bool wasEmpty = _currentSession!.messages.isEmpty;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    final botMessage = ChatMessage(
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, userMessage, botMessage],
      );
      _isSending = true;
    });

    // If this was the first user message in a new chat, generate a readable title
    // from the first few words of the message and persist it.
    if (wasEmpty) {
      final generated = _generateTitleFromMessage(text);
      _currentSession = _currentSession!.copyWith(title: generated);
      await _sessionManager.updateSession(_currentSession!, _allSessions);
      _allSessions = await _sessionManager.loadSessions();
      setState(() {});
    }

    _controller.clear();
    _scrollToBottom();

    try {
      // Build context from last 10 messages
      final contextMessages = _currentSession!.messages.length <= 10
          ? _currentSession!.messages
          : _currentSession!.messages.sublist(
              _currentSession!.messages.length - 10,
            );

      final apiMessages = contextMessages
          .map((m) => ollama.ChatMessage(role: m.role, content: m.content))
          .toList();

      final stream = ollamaClient.chat(apiMessages, model: 'qwen3:0.6b');

      String accumulatedContent = '';
      await for (final chunk in stream) {
        final content = chunk.message?.content;
        if (content == null) continue;

        accumulatedContent += content;

        setState(() {
          final updatedMessages = List<ChatMessage>.from(
            _currentSession!.messages,
          );
          updatedMessages[updatedMessages.length - 1] = ChatMessage(
            role: 'assistant',
            content: accumulatedContent,
            timestamp: botMessage.timestamp,
          );
          _currentSession = _currentSession!.copyWith(
            messages: updatedMessages,
          );
        });

        _scrollToBottom();
      }

      await _sessionManager.updateSession(_currentSession!, _allSessions);
    } catch (e, st) {
      final updatedMessages = List<ChatMessage>.from(_currentSession!.messages);
      updatedMessages[updatedMessages.length - 1] = ChatMessage(
        role: 'assistant',
        content: 'Error: $e',
        timestamp: botMessage.timestamp,
      );
      setState(() {
        _currentSession = _currentSession!.copyWith(messages: updatedMessages);
      });
      print('Error streaming reply: $e\n$st');
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _currentSession?.title ?? 'OLLAMA chatbot',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _currentSession == null || _currentSession!.messages.isEmpty
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
                      itemCount: _currentSession!.messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            _currentSession!.messages[_currentSession!
                                    .messages
                                    .length -
                                1 -
                                index];
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: _primaryColor),
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Chat History',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_allSessions.length} conversation${_allSessions.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle, color: _primaryColor),
            title: Text(
              'New Chat',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: _createNewChat,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _allSessions.length,
              itemBuilder: (context, index) {
                final session = _allSessions[_allSessions.length - 1 - index];
                final isActive = session.id == _currentSession?.id;

                final tile = ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: isActive ? _primaryColor : Colors.grey,
                  ),
                  title: Text(
                    session.title,
                    style: GoogleFonts.inter(
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive ? _primaryColor : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${session.messages.length} messages',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _showDeleteConfirmation(session),
                  ),
                  selected: isActive,
                  selectedTileColor: _primaryColor.withOpacity(0.1),
                  onTap: () => _switchToSession(session),
                );

                final delay = (index * 80).ms;
                return tile
                    .animate()
                    .slideX(
                      begin: -0.6,
                      end: 0.0,
                      delay: delay,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(delay: delay, duration: 300.ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat', style: GoogleFonts.inter()),
        content: Text(
          'Are you sure you want to delete "${session.title}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSession(session);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final bg = msg.isUser ? _primaryColor : Colors.grey.shade200;
    final textColor = msg.isUser ? Colors.white : Colors.black87;
    final align = msg.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

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
                ? Text(msg.content, style: GoogleFonts.inter(color: textColor))
                : _buildMarkdownWithThinking(msg.content, textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownWithThinking(String text, Color textColor) {
    // If thinking is disabled, strip all <think>...</think> blocks and render the rest
    if (!enableThinking) {
      final cleaned = text.replaceAll(
        RegExp(r'<think>.*?<\/think>', dotAll: true),
        '',
      );
      return MarkdownBody(
        data: cleaned,
        styleSheet: MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(p: GoogleFonts.inter(color: textColor)),
      );
    }

    // Handle <think> tags (thinking enabled)
    final openIdx = text.indexOf('<think>');
    if (openIdx == -1) {
      return MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(p: GoogleFonts.inter(color: textColor)),
      );
    }

    final closeIdx = text.indexOf('</think>');
    if (closeIdx == -1) {
      final thinking = text.substring(openIdx + 7);
      return Text(
        thinking,
        style: GoogleFonts.inter(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Split and render thinking + normal parts
    final beforeThink = text.substring(0, openIdx);
    final thinking = text.substring(openIdx + 7, closeIdx);
    final afterThink = text.substring(closeIdx + 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (beforeThink.isNotEmpty)
          MarkdownBody(
            data: beforeThink,
            styleSheet: MarkdownStyleSheet.fromTheme(
              Theme.of(context),
            ).copyWith(p: GoogleFonts.inter(color: textColor)),
          ),
        if (thinking.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              thinking,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (afterThink.isNotEmpty)
          _buildMarkdownWithThinking(afterThink, textColor),
      ],
    );
  }

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
