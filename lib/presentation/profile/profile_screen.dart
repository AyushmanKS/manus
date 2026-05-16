import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/theme_notifier.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : AppColors.textPrimaryLight;

    final ThemeMode themeMode = ref.watch(themeProvider);
    final (String, String) themeInfo = switch (themeMode) {
      ThemeMode.system => ('Follow system', AppAssets.contrastSvg),
      ThemeMode.light => ('Light mode', AppAssets.lightModeSvg),
      ThemeMode.dark => ('Dark mode', AppAssets.darkModeSvg),
    };

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 32),
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  AppColors.primary,
                                  Theme.of(context).colorScheme.primary,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.iconDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'user@example.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildGroup(context, <Widget>[
                        _AppearanceMenu(
                          iconColor: iconColor,
                          themeInfo: themeInfo,
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          context,
                          SvgPicture.asset(
                            AppAssets.accountSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          'Account',
                          onTap: () => AppLogger.info('Account tapped'),
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          context,
                          SvgPicture.asset(
                            AppAssets.taskSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          'Scheduled Tasks',
                          onTap: () => AppLogger.info('Scheduled Tasks tapped'),
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          context,
                          Icon(
                            Icons.menu_book_outlined,
                            size: 22,
                            color: iconColor,
                          ),
                          'Knowledge',
                          onTap: () => AppLogger.info('Knowledge tapped'),
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          context,
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 22,
                            color: iconColor,
                          ),
                          'Manus Pro',
                          onTap: () => AppLogger.info('Manus Pro tapped'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildGroup(context, <Widget>[
                        _buildMenuItem(
                          context,
                          SvgPicture.asset(
                            AppAssets.helpSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          'Help and Support',
                          onTap: () =>
                              AppLogger.info('Help and Support tapped'),
                        ),
                        _buildDivider(isDark),
                        _buildMenuItem(
                          context,
                          SvgPicture.asset(
                            AppAssets.infoSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          'About',
                          onTap: () => AppLogger.info('About tapped'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.iconDark
        : AppColors.textPrimaryLight;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: iconColor,
              ),
            ),
          ),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.iconDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(final BuildContext context, final List<Widget> children) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem(
    final BuildContext context,
    final Widget leading,
    final String title, {
    required final VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            SizedBox(width: 22, height: 22, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(final bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 50,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }
}

class _AppearanceMenu extends ConsumerWidget {
  const _AppearanceMenu({required this.iconColor, required this.themeInfo});

  final Color iconColor;
  final (String, String) themeInfo;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeMode currentMode = ref.watch(themeProvider);

    return PopupMenuButton<ThemeMode>(
      offset: const Offset(1000, 48),
      elevation: 0.5,
      tooltip: '',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSelected: (final ThemeMode mode) {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        unawaited(HapticFeedback.mediumImpact());
      },
      itemBuilder: (final BuildContext context) => <PopupMenuEntry<ThemeMode>>[
        _buildPopupItem(
          context,
          ThemeMode.system,
          'Follow system',
          AppAssets.contrastSvg,
          currentMode == ThemeMode.system,
        ),
        _buildDivider(isDark),
        _buildPopupItem(
          context,
          ThemeMode.light,
          'Light mode',
          AppAssets.lightModeSvg,
          currentMode == ThemeMode.light,
        ),
        _buildDivider(isDark),
        _buildPopupItem(
          context,
          ThemeMode.dark,
          'Dark mode',
          AppAssets.darkModeSvg,
          currentMode == ThemeMode.dark,
        ),
      ],
      child: InkWell(
        onTap: null, // Let PopupMenuButton handle tap
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: SvgPicture.asset(
                    themeInfo.$2,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(themeInfo.$1, style: const TextStyle(fontSize: 15)),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<ThemeMode> _buildDivider(final bool isDark) {
    return const PopupMenuDivider(height: 1);
  }

  PopupMenuItem<ThemeMode> _buildPopupItem(
    final BuildContext context,
    final ThemeMode mode,
    final String label,
    final String iconPath,
    final bool isSelected,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color itemIconColor = isDark
        ? AppColors.iconDark
        : Theme.of(context).colorScheme.onSurface;

    return PopupMenuItem<ThemeMode>(
      value: mode,
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 20,
            child: isSelected
                ? SvgPicture.asset(
                    AppAssets.checkSvg,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.iconDark
                          : Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
          const SizedBox(width: 32),
          SvgPicture.asset(
            iconPath,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(itemIconColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
