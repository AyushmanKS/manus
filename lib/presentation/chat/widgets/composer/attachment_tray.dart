import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/models/attachment.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/services/attachment_service.dart';
import 'package:manus/presentation/chat/providers/attachment_provider.dart';

class AttachmentTray extends ConsumerWidget {
  const AttachmentTray({required this.iconColor, required this.onClose, super.key});

  final Color iconColor;
  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final AttachmentService service = ref.read(attachmentServiceProvider);
    final AttachmentNotifier notifier = ref.read(attachmentProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TrayItem(
              iconAsset: AppAssets.cameraSvg,
              label: 'Camera',
              iconColor: iconColor,
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                unawaited(() async {
                  final Attachment? result = await service.pickFromCamera(context);
                  if (result != null) {
                    notifier.add(result);
                    onClose();
                  }
                }());
              },
            ),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: TrayItem(
              iconAsset: AppAssets.pictureSvg,
              label: 'Picture',
              iconColor: iconColor,
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                unawaited(() async {
                  final List<Attachment> results = await service.pickFromGallery(context);
                  if (results.isNotEmpty) {
                    for (final Attachment result in results) {
                      notifier.add(result);
                    }
                    onClose();
                  }
                }());
              },
            ),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: TrayItem(
              iconAsset: AppAssets.attachSvg,
              label: 'File',
              iconColor: iconColor,
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                unawaited(() async {
                  final List<Attachment> results = await service.pickFiles(context);
                  if (results.isNotEmpty) {
                    for (final Attachment result in results) {
                      notifier.add(result);
                    }
                    onClose();
                  }
                }());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrayItem extends StatelessWidget {
  const TrayItem({
    required this.iconAsset,
    required this.label,
    required this.iconColor,
    required this.onTap,
    super.key,
  });

  final String iconAsset;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark
        ? AppColors.composerIconBgDark
        : AppColors.composerIconBgLight;
    final Color labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: 28.0,
                  height: 28.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
