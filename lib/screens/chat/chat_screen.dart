import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    context
        .read<ChatProvider>()
        .reset(conversationId: widget.conversationId);

    final user = context.read<AuthProvider>().usuario;
    if (user != null && widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHistory(
          userId: user.id,
          conversationId: widget.conversationId!,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory({
    required String userId,
    required String conversationId,
  }) async {
    final chatProvider = context.read<ChatProvider>();
    try {
      await chatProvider.loadConversation(
        conversationId: conversationId,
        userId: userId,
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleSend(ChatProvider chatProvider) async {
    final user = context.read<AuthProvider>().usuario;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesion para chatear.')),
      );
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty || chatProvider.isSending) return;

    _messageController.clear();

    try {
      final sendFuture =
          chatProvider.sendMessage(userId: user.id, content: text);
      _scrollToBottom();
      await sendFuture;
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.usuario;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2F5F8),
      appBar: AppBar(
        title: const Text('Chat AdoPets'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            final messages = chatProvider.messages;

            return Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: chatProvider.isLoadingHistory
                        ? const Center(child: CircularProgressIndicator())
                        : messages.isEmpty
                            ? _EmptyState(onSampleTap: () {
                                if (user != null) {
                                  _messageController.text =
                                      'Hola, necesito informacion sobre adopcion.';
                                  _handleSend(chatProvider);
                                }
                              })
                            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final ChatMessage message = messages[index];
                                  return ChatBubble(
                                    message: message,
                                    isUser: message.isUser,
                                  );
                                },
                              ),
                  ),
                ),
                _buildInputArea(chatProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final isSending = chatProvider.isSending;
    final sendColor = theme.colorScheme.primary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(chatProvider),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 12),
            Ink(
              decoration: ShapeDecoration(
                color: isSending
                    ? sendColor.withOpacity(0.4)
                    : sendColor,
                shape: const CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: isSending ? Colors.white70 : Colors.white,
                ),
                onPressed:
                    isSending ? null : () => _handleSend(chatProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onSampleTap;

  const _EmptyState({required this.onSampleTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Empieza la conversacion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enviale un mensaje al asistente para recibir ayuda sobre adopciones, citas y mas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onSampleTap,
              icon: const Icon(Icons.flash_on),
              label: const Text('Probar mensaje'),
            ),
          ],
        ),
      ),
    );
  }
}
