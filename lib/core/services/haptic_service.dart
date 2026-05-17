import 'dart:io';
import 'package:flutter/services.dart';
import 'package:manus/core/utils/app_logger.dart';

class HapticService {
  HapticService._();
  static Future<void> light() async {
    try {
      if (Platform.isAndroid) {
        await HapticFeedback.vibrate();
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      AppLogger.error('HapticService: failed to trigger light haptic', e);
    }
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.error('HapticService: failed to trigger medium haptic', e);
    }
  }

  static Future<void> selection() async {
    try {
      if (Platform.isAndroid) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (e) {
      AppLogger.error('HapticService: failed to trigger selection haptic', e);
    }
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      AppLogger.error('HapticService: failed to trigger heavy haptic', e);
    }
  }
}
