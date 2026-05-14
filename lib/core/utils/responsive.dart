import 'package:flutter/widgets.dart';

// --- SCREEN BREAKPOINTS ---
// These are the logical widths in 'dp' that we'll use to define our layouts.
// We are targeting the specific devices mentioned in the assignment.

/// Width of a small phone like iPhone 13 mini / SE (375 dp).
const double kSmallPhoneWidthDp = 375.0;

/// Width of a standard phone like Pixel 7 / iPhone 15 (around 390-412 dp).
const double kStandardPhoneWidthDp = 412.0;

/// Width of a large phone like iPhone 15 Pro Max (430 dp).
const double kLargePhoneWidthDp = 430.0;

/// Context-based responsive helpers
class Responsive {
  final BuildContext context;
  late final double _width;

  Responsive(this.context) {
    _width = MediaQuery.of(context).size.width;
  }

  /// Returns true if the screen width is less than or equal to the small phone breakpoint.
  bool get isSmallPhone => _width <= kSmallPhoneWidthDp;
  
  /// Returns true if the screen width is between the small and standard phone breakpoints.
  bool get isStandardPhone => _width > kSmallPhoneWidthDp && _width <= kStandardPhoneWidthDp;

  /// Returns true if the screen width is larger than the standard phone breakpoint.
  bool get isLargePhone => _width > kStandardPhoneWidthDp;

  /// A flexible method to return a value based on the current screen size.
  /// This is the primary tool for adaptive layouts. It allows you to specify
  /// different FIXED values for different screen sizes, rather than scaling them.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(
  ///   Responsive(context).responsiveValue<double>(
  ///     small: 12.0,
  ///     standard: 16.0,
  ///     large: 20.0,
  ///   ),
  /// ),
  /// ```
  T responsiveValue<T>({
    required T small,
    T? standard,
    T? large,
  }) {
    if (isLargePhone && large != null) return large;
    if ((isStandardPhone || isLargePhone) && standard != null) return standard;
    return small;
  }
}
