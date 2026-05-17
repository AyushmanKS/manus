import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/router/app_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/services/share_service.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/notifiers/chat_status_notifiers.dart';
import 'package:manus/presentation/widgets/tappable_opacity.dart';

class ChatHeader extends ConsumerWidget {
  const ChatHeader({required this.composerFocusNode, super.key});

  final FocusNode composerFocusNode;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final String selectedModel = ref.watch<String>(selectedModelProvider);
    final List<ChatMessage> messages = ref.watch(chatProvider);
    final bool canShare = messages.isNotEmpty;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : AppColors.textPrimaryLight;
    final Color mutedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
      child: Row(
        children: <Widget>[
          TappableOpacity(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 8.0),
              child: SvgPicture.asset(
                AppAssets.menuSvg,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            onSelected: (final String model) {
              ref.read(selectedModelProvider.notifier).set(model);
              composerFocusNode.requestFocus();
            },
            itemBuilder: (final BuildContext context) {
              final List<(String, String)> models = <(String, String)>[
                ('Manus 1.6 Lite', 'Fast and efficient'),
                ('Manus 1.6', 'Balanced'),
                ('Manus 2.0 Pro', 'Most capable'),
              ];
              return models.map((final (String, String) model) {
                final bool isSelected = selectedModel == model.$1;
                return PopupMenuItem<String>(
                  value: model.$1,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            model.$1,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(fontSize: 15),
                          ),
                          Text(
                            model.$2,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: TappableOpacity(
              onTap: null, // PopupMenuButton handles tap
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      selectedModel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      AppAssets.downArrowSvg,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        mutedColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: canShare ? 1.0 : 0.3,
            child: TappableOpacity(
              onTap: canShare
                  ? () => ShareService.shareConversation(messages)
                  : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 8.0),
                child: SvgPicture.asset(
                  AppAssets.shareSvg,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          TappableOpacity(
            onTap: () => context.push(AppRouter.profile),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 8.0, 8.0, 8.0),
              child: SvgPicture.asset(
                AppAssets.profileSvg,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
