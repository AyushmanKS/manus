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
                        _ThemeSelectorItem(
                          iconColor: iconColor,
                          themeInfo: themeInfo,
                        ),
                        _buildDivider(isDark),
                        _MenuButton(
                          leading: SvgPicture.asset(
                            AppAssets.accountSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: 'Account',
                          onTap: () => AppLogger.info('Account tapped'),
                        ),
                        _buildDivider(isDark),
                        _MenuButton(
                          leading: SvgPicture.asset(
                            AppAssets.taskSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: 'Scheduled Tasks',
                          onTap: () => AppLogger.info('Scheduled Tasks tapped'),
                        ),
                        _buildDivider(isDark),
                        _MenuButton(
                          leading: Icon(
                            Icons.menu_book_outlined,
                            size: 22,
                            color: iconColor,
                          ),
                          title: 'Knowledge',
                          onTap: () => AppLogger.info('Knowledge tapped'),
                        ),
                        _buildDivider(isDark),
                        _MenuButton(
                          leading: Icon(
                            Icons.workspace_premium_outlined,
                            size: 22,
                            color: iconColor,
                          ),
                          title: 'Manus Pro',
                          onTap: () => AppLogger.info('Manus Pro tapped'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildGroup(context, <Widget>[
                        _MenuButton(
                          leading: SvgPicture.asset(
                            AppAssets.helpSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: 'Help and Support',
                          onTap: () =>
                              AppLogger.info('Help and Support tapped'),
                        ),
                        _buildDivider(isDark),
                        _MenuButton(
                          leading: SvgPicture.asset(
                            AppAssets.infoSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: 'About',
                          onTap: () => AppLogger.info('About tapped'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildGroup(context, <Widget>[
                        _MenuButton(
                          leading: SvgPicture.asset(
                            AppAssets.logoutSvg,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: 'Logout',
                          showArrow: false,
                          onTap: () => ref.read(authProvider.notifier).logout(),
                        ),
                      ]),
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
            'Manus',
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

  Widget _buildDivider(final bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 50,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.leading,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  final Widget leading;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isPressed = false;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return GestureDetector(
      onTapDown: (final _) => setState(() => _isPressed = true),
      onTapUp: (final _) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 22,
                height: 22,
                child: Center(child: widget.leading),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.title, style: const TextStyle(fontSize: 15)),
              ),
              if (widget.showArrow)
                SvgPicture.asset(
                  AppAssets.rightArrowSvg,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(mutedColor, BlendMode.srcIn),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectorItem extends ConsumerStatefulWidget {
  const _ThemeSelectorItem({required this.iconColor, required this.themeInfo});

  final Color iconColor;
  final (String, String) themeInfo;

  @override
  ConsumerState<_ThemeSelectorItem> createState() => _ThemeSelectorItemState();
}

class _ThemeSelectorItemState extends ConsumerState<_ThemeSelectorItem> {
  bool _isPressed = false;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeMode currentMode = ref.watch(themeProvider);
    final Color mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

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
      child: Listener(
        onPointerDown: (final _) => setState(() => _isPressed = true),
        onPointerUp: (final _) => setState(() => _isPressed = false),
        onPointerCancel: (final _) => setState(() => _isPressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _isPressed ? 0.4 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.themeInfo.$2,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        widget.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.themeInfo.$1,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                SvgPicture.asset(
                  AppAssets.rightArrowSvg,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(mutedColor, BlendMode.srcIn),
                ),
              ],
            ),
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
                          : Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 16),
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
