import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/chat_history_service.dart';
import '../providers/ai_chat_providers.dart';

class ChatHistoryMenu extends ConsumerStatefulWidget {
  final VoidCallback onSessionChanged;
  const ChatHistoryMenu({super.key, required this.onSessionChanged});

  @override
  ConsumerState<ChatHistoryMenu> createState() => _ChatHistoryMenuState();
}

class _ChatHistoryMenuState extends ConsumerState<ChatHistoryMenu> {
  final _historyService = ChatHistoryService();
  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _historyService.getAllSessions();
    final currentId = await _historyService.getCurrentSessionId();
    setState(() {
      _sessions = sessions..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _currentSessionId = currentId;
      _isLoading = false;
    });
  }

  Future<void> _createNewSession() async {
    await ref.read(aiChatProvider.notifier).clearChat();
    await _loadSessions();
    widget.onSessionChanged();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _switchSession(String sessionId) async {
    await ref.read(aiChatProvider.notifier).loadSession(sessionId);
    setState(() => _currentSessionId = sessionId);
    widget.onSessionChanged();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this chat?'),
        content: const Text('This will permanently delete this chat session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiChatProvider.notifier).deleteSession(sessionId);
      await _loadSessions();
      widget.onSessionChanged();
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This will permanently delete all chat sessions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiChatProvider.notifier).clearAllHistory();
      await _loadSessions();
      widget.onSessionChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.only(top: 70, right: 16), // 👈 position near top-right button
      alignment: Alignment.topRight,
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'New Chat',
                    onPressed: _createNewSession,
                  ),
                ],
              ),
              const Divider(),

              // List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: colorScheme.outline),
                            const SizedBox(height: 8),
                            Text(
                              'No chat history yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => Divider(color: colorScheme.outlineVariant),
                        itemBuilder: (context, index) {
                          final s = _sessions[index];
                          final isActive = s.id == _currentSessionId;
                          final df = DateFormat('MMM d, h:mm a');

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isActive ? null : () => _switchSession(s.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isActive ? colorScheme.primaryContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat,
                                    color: isActive
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${s.messageCount} msg • ${df.format(s.updatedAt)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: colorScheme.error,
                                    onPressed: () => _deleteSession(s.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              if (_sessions.isNotEmpty) ...[
                const Divider(),
                Center(
                  child: TextButton.icon(
                    onPressed: _clearAllHistory,
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
