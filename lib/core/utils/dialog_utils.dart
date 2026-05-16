import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showManusConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  required String cancelLabel,
  required VoidCallback onConfirm,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => context.pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            context.pop(true);
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
