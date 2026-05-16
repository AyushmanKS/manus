import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({this.isSearching = false, super.key});

  final bool isSearching;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AppAssets.chatBubbleSvg,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
              iconColor.withValues(alpha: 0.2),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No chats match your search' : 'No conversations yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: iconColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
