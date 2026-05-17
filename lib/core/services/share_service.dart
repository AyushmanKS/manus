import 'package:manus/data/models/chat_message.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareConversation(final List<ChatMessage> messages) async {
    if (messages.isEmpty) return;

    final String markdown = _formatToMarkdown(messages);
    await Share.share(markdown, subject: 'Manus Conversation');
  }

  static String _formatToMarkdown(final List<ChatMessage> messages) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('# Manus Conversation\n');

    for (final ChatMessage message in messages) {
      final String role = message.role == MessageRole.user ? 'User' : 'Manus';
      buffer.writeln('### $role');
      buffer.writeln(message.text);
      buffer.writeln('\n---\n');
    }

    return buffer.toString();
  }
}
