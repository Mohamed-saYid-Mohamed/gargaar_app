import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_provider.dart';
import '../models/incident_message_model.dart';
import '../services/chat_service.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';

class IncidentChatScreen extends ConsumerStatefulWidget {
  final String incidentId;
  final String? incidentType;
  final String? status;

  const IncidentChatScreen({
    super.key,
    required this.incidentId,
    this.incidentType,
    this.status,
  });

  @override
  ConsumerState<IncidentChatScreen> createState() => _IncidentChatScreenState();
}

class _IncidentChatScreenState extends ConsumerState<IncidentChatScreen> {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening the chat
    Future.delayed(Duration.zero, () {
      _chatService.markMessagesAsRead(widget.incidentId, 'user');
    });
  }

  void _sendMessage(String message) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        incidentId: widget.incidentId,
        senderId: user.id,
        senderRole: 'user',
        message: message,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incident ID: ${widget.incidentId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (widget.incidentType != null)
              Text(
                '${widget.incidentType} • ${widget.status ?? 'Active'}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Support Online',
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
        elevation: 0.5,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<IncidentMessageModel>>(
              stream: _chatService.watchMessages(widget.incidentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading messages: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                // Auto-scroll logic for new messages
                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation with admin authorities.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false, // Messages flow Oldest -> Latest (Latest at bottom)
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == user?.id;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          ChatInput(
            onSend: _sendMessage,
            isLoading: _isSending,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
