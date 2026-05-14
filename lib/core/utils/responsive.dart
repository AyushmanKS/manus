import 'package:flutter/widgets.dart';

const double kSmallPhoneWidthDp = 375.0;
const double kStandardPhoneWidthDp = 412.0;
const double kLargePhoneWidthDp = 430.0;

class Responsive {
  final BuildContext context;
  late final double _width;

  Responsive(this.context) {
    _width = MediaQuery.of(context).size.width;
  }

  bool get isSmallPhone => _width <= kSmallPhoneWidthDp;
  
  bool get isStandardPhone => _width > kSmallPhoneWidthDp && _width <= kStandardPhoneWidthDp;

  bool get isLargePhone => _width > kStandardPhoneWidthDp;

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
