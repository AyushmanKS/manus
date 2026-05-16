import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditingMessage {
  const EditingMessage({required this.messageId, required this.originalText});

  final String messageId;
  final String originalText;
}

class EditingNotifier extends Notifier<EditingMessage?> {
  @override
  EditingMessage? build() => null;

  void startEditing(final String messageId, final String originalText) {
    state = EditingMessage(messageId: messageId, originalText: originalText);
  }

  void cancelEditing() {
    state = null;
  }

  void confirmEditing() {
    state = null;
  }
}

final NotifierProvider<EditingNotifier, EditingMessage?>
editingMessageProvider = NotifierProvider<EditingNotifier, EditingMessage?>(
  EditingNotifier.new,
);
