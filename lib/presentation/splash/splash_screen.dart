import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/presentation/design_system/widgets/meta_attribution.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      _controller.forward();
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/chat');
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foregroundColor = theme.colorScheme.onSurface;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child:
                SvgPicture.asset(
                      AppAssets.logoSvg,
                      width: 100,
                      height: 100,
                      colorFilter: ColorFilter.mode(
                        foregroundColor,
                        BlendMode.srcIn,
                      ),
                    )
                    .animate(controller: _controller, autoPlay: false)
                    .fadeIn(duration: 800.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),
          ),
          const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 60.0),
                  child: MetaAttribution(),
                ),
              )
              .animate(controller: _controller, autoPlay: false)
              .fadeIn(duration: 1000.ms, delay: 300.ms),
        ],
      ),
    );
  }
}