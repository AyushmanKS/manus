import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/models/attachment.dart';
import 'package:manus/core/utils/globals.dart';

class AttachmentNotifier extends Notifier<List<Attachment>> {
  @override
  List<Attachment> build() => <Attachment>[];

  void add(final Attachment a) {
    if (state.length >= 5) {
      snackbarKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 attachments allowed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    state = <Attachment>[...state, a];
  }

  void remove(final String path) {
    state = state.where((final Attachment a) => a.path != path).toList();
  }

  void reorder(final int oldIndex, final int newIndex) {
    int index = newIndex;
    if (oldIndex < index) {
      index -= 1;
    }
    final List<Attachment> list = <Attachment>[...state];
    final Attachment item = list.removeAt(oldIndex);
    list.insert(index, item);
    state = list;
  }

  void clear() {
    state = <Attachment>[];
  }
}

final NotifierProvider<AttachmentNotifier, List<Attachment>>
attachmentProvider = NotifierProvider<AttachmentNotifier, List<Attachment>>(
  AttachmentNotifier.new,
);
