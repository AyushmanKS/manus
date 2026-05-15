import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';

class EmptyChatState extends StatelessWidget {
  const EmptyChatState({required this.onSuggestionTap, super.key});

  final void Function(String text) onSuggestionTap;

  static const List<String> _suggestions = <String>[
    'Analyze this image',
    'Help me with code',
    'Summarize text',
    'Write a story',
  ];

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color logoColor = isDark ? AppColors.white : AppColors.black;
    final Color chipBg =
        isDark ? AppColors.composerBgDark : AppColors.composerBgLight;
    final Color chipBorder =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final Color chipText =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              AppAssets.logoSvg,
              width: 40.0,
              height: 40.0,
              colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 32.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map(
                    (final String suggestion) => GestureDetector(
                      onTap: () => onSuggestionTap(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: chipBorder),
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            color: chipText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList()
                  .animate(interval: 60.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
