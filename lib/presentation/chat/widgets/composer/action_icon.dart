import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/presentation/widgets/tappable_opacity.dart';

class ActionIcon extends StatelessWidget {
  const ActionIcon({
    required this.asset,
    this.onTap,
    required this.colorFilter,
    this.decoration,
    this.padding = 0.0,
    this.isBold = false,
    this.size = 18.0,
    super.key,
  });

  final String asset;
  final VoidCallback? onTap;
  final ColorFilter colorFilter;
  final BoxDecoration? decoration;
  final double padding;
  final bool isBold;
  final double size;

  @override
  Widget build(final BuildContext context) {
    const double strength = 0.3;
    final Widget icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: colorFilter,
    );

    return TappableOpacity(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(padding),
        decoration: decoration,
        child: isBold
            ? Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(strength, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength, 0),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, strength),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -strength),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(strength * 0.65, strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength * 0.65, strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(strength * 0.65, -strength * 0.65),
                    child: icon,
                  ),
                  Transform.translate(
                    offset: const Offset(-strength * 0.65, -strength * 0.65),
                    child: icon,
                  ),
                  icon,
                ],
              )
            : icon,
      ),
    );
  }
}
