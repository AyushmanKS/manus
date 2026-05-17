import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.composerBgDark : AppColors.white;
    final Color cancelBtnColor = isDark
        ? AppColors.cancelBtnDark
        : AppColors.greyE6;
    const Color logoutBtnColor = AppColors.logoutRed;
    final Color titleColor = isDark ? AppColors.white : AppColors.black;
    const Color descColor = AppColors.textDescriptionGrey;
    const Color logoutTextColor = AppColors.whiteFD;
    final Color cancelTextColor = isDark
        ? AppColors.whiteFD
        : AppColors.cancelBtnDark;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Are you sure to Log out?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will not lose your data if you log out. You can still log in to this account.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: descColor, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: cancelBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: cancelTextColor,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).logout();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: logoutBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Log out',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: logoutTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
