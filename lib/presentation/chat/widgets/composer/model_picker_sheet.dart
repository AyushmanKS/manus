import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/theme/app_colors.dart';

class ModelPickerSheet extends StatelessWidget {
  const ModelPickerSheet({required this.isDark, super.key});

  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    final Color bg = isDark ? AppColors.composerBgDark : AppColors.composerBgLight;
    final Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 36.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: divider,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Select Model',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16.0),
          ...<String>[
            'Manus Default',
            'GPT-4o',
            'Claude 3.5',
            'Gemini 1.5 Pro',
          ].map<Widget>(
            (final String model) => Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          model,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: divider, height: 1.0, thickness: 1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
