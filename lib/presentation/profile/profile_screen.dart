import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/theme_notifier.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
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
                    const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
                      _buildMenuItem(
                        context,
                        SvgPicture.asset(
                          AppAssets.contrastSvg,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        'Appearance',
                        onTap: () => _showAppearanceSheet(context),
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
                        const Icon(Icons.menu_book_outlined, size: 22),
                        'Knowledge',
                        onTap: () => AppLogger.info('Knowledge tapped'),
                      ),
                      _buildDivider(isDark),
                      _buildMenuItem(
                        context,
                        const Icon(Icons.workspace_premium_outlined, size: 22),
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
                        onTap: () => AppLogger.info('Help and Support tapped'),
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
                      onPressed: () => ref.read(authProvider.notifier).logout(),
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
    );
  }

  Widget _buildHeader(final BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          const Text(
            'Profile',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(final BuildContext context, final List<Widget> children) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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

  void _showAppearanceSheet(final BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (final BuildContext context) => const _AppearanceSheet(),
    );
  }
}

class _AppearanceSheet extends ConsumerStatefulWidget {
  const _AppearanceSheet();

  @override
  ConsumerState<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends ConsumerState<_AppearanceSheet> {
  @override
  Widget build(final BuildContext context) {
    final ThemeMode currentMode = ref.watch(themeProvider);
    final double cardWidth = (MediaQuery.of(context).size.width - 80) / 3;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _AppearanceCard(
                  width: cardWidth,
                  label: 'Light',
                  icon: Icons.light_mode,
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () => _updateTheme(ThemeMode.light),
                ),
                _AppearanceCard(
                  width: cardWidth,
                  label: 'System',
                  icon: Icons.brightness_auto,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () => _updateTheme(ThemeMode.system),
                ),
                _AppearanceCard(
                  width: cardWidth,
                  label: 'Dark',
                  icon: Icons.dark_mode,
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () => _updateTheme(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _updateTheme(final ThemeMode mode) {
    ref.read(themeProvider.notifier).setThemeMode(mode);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        context.pop();
      }
    });
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.width,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 24),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
