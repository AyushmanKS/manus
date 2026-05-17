import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/models/attachment.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/chat/providers/attachment_provider.dart';

class AttachmentPreviewRow extends ConsumerWidget {
  const AttachmentPreviewRow({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final List<Attachment> attachments = ref.watch(attachmentProvider);
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: attachments.length,
        separatorBuilder: (final BuildContext context, final int index) =>
            const SizedBox(width: 8),
        itemBuilder: (final BuildContext context, final int index) {
          final Attachment attachment = attachments[index];
          return AttachmentPreviewItem(
            attachment: attachment,
            onRemove: () =>
                ref.read(attachmentProvider.notifier).remove(attachment.path),
          );
        },
      ),
    );
  }
}

class AttachmentPreviewItem extends StatelessWidget {
  const AttachmentPreviewItem({
    required this.attachment,
    required this.onRemove,
    super.key,
  });

  final Attachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark
                  ? AppColors.composerIconBgDark
                  : AppColors.composerIconBgLight,
            ),
            clipBehavior: Clip.antiAlias,
            child: attachment.type == AttachmentType.image
                ? Image.file(
                    File(attachment.path),
                    fit: BoxFit.cover,
                  )
                : Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.insert_drive_file, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileName(attachment.name),
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(attachment.sizeBytes),
                          style: TextStyle(
                            fontSize: 7,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.black : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.7, 0.7),
          curve: Curves.easeOutBack,
        ).fadeIn(duration: 200.ms);
  }

  String _formatFileName(final String name) {
    if (name.length <= 12) return name;
    final List<String> parts = name.split('.');
    if (parts.length < 2) return name.substring(0, 8);
    final String ext = parts.last;
    final String base = parts.first;
    return '${base.substring(0, math.min(8, base.length))}.$ext';
  }

  String _formatFileSize(final int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
