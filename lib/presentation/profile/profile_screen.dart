import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/theme_notifier.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/presentation/auth/notifiers/auth_notifier.dart';
import 'package:manus/presentation/design_system/widgets/meta_attribution.dart';
import 'package:manus/presentation/profile/widgets/menu_button.dart';
import 'package:manus/presentation/profile/widgets/profile_group.dart';
import 'package:manus/presentation/profile/widgets/profile_header.dart';
import 'package:manus/presentation/profile/widgets/profile_info.dart';
import 'package:manus/presentation/profile/widgets/theme_selector_item.dart';

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
              const ProfileHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const ProfileInfo(),
                      const SizedBox(height: 32),
                      ProfileGroup(
                        children: <Widget>[
                          ThemeSelectorItem(
                            iconColor: iconColor,
                            themeInfo: themeInfo,
                          ),
                          const ProfileDivider(),
                          MenuButton(
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
                          const ProfileDivider(),
                          MenuButton(
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
                            onTap: () =>
                                AppLogger.info('Scheduled Tasks tapped'),
                          ),
                          const ProfileDivider(),
                          MenuButton(
                            leading: Icon(
                              Icons.menu_book_outlined,
                              size: 22,
                              color: iconColor,
                            ),
                            title: 'Knowledge',
                            onTap: () => AppLogger.info('Knowledge tapped'),
                          ),
                          const ProfileDivider(),
                          MenuButton(
                            leading: Icon(
                              Icons.workspace_premium_outlined,
                              size: 22,
                              color: iconColor,
                            ),
                            title: 'Manus Pro',
                            onTap: () => AppLogger.info('Manus Pro tapped'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ProfileGroup(
                        children: <Widget>[
                          MenuButton(
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
                          const ProfileDivider(),
                          MenuButton(
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      ProfileGroup(
                        children: <Widget>[
                          MenuButton(
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
                            onTap: () =>
                                ref.read(authProvider.notifier).logout(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: MetaAttribution(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
