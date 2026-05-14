import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:manus/core/constants/app_assets.dart';

void main() {
  final Directory dir = Directory('assets/images');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final Uint8List originalBytes = File(AppAssets.logoPng).readAsBytesSync();
  final img.Image? originalImage = img.decodeImage(originalBytes);
  if (originalImage == null) {
    log('Failed to decode original logo.');
    return;
  }

  final img.Image standardCanvas = img.Image(
    width: 1024,
    height: 1024,
    numChannels: 4,
  );
  img.fill(standardCanvas, color: img.ColorRgba8(0, 0, 0, 0));

  const int standardLogoSize = 768;
  final img.Image resizedLogo = img.copyResize(
    originalImage,
    width: standardLogoSize,
    height: standardLogoSize,
  );

  img.compositeImage(
    standardCanvas,
    resizedLogo,
    dstX: (1024 - standardLogoSize) ~/ 2,
    dstY: (1024 - standardLogoSize) ~/ 2,
  );

  File(AppAssets.logoSplashPng).writeAsBytesSync(img.encodePng(standardCanvas));

  final img.Image paddedCanvas = img.Image(
    width: 2048,
    height: 2048,
    numChannels: 4,
  );
  img.fill(paddedCanvas, color: img.ColorRgba8(0, 0, 0, 0));

  img.compositeImage(
    paddedCanvas,
    resizedLogo,
    dstX: (2048 - standardLogoSize) ~/ 2,
    dstY: (2048 - standardLogoSize) ~/ 2,
  );

  File(
    AppAssets.logoSplashAndroid12Png,
  ).writeAsBytesSync(img.encodePng(paddedCanvas));

  log('Generated PNG assets in assets/images/');
}
