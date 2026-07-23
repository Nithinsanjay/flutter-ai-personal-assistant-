import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  /// The width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Whether the screen is in landscape orientation.
  bool get isLandscape => screenWidth > screenHeight;

  // Base design dimensions (standard mobile layout size)
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  /// Horizontal scale factor.
  double get widthScale => screenWidth / _designWidth;

  /// Vertical scale factor.
  double get heightScale => screenHeight / _designHeight;

  /// Scale a width value dynamically based on screen width.
  double w(double width) => width * widthScale;

  /// Scale a height value dynamically based on screen height.
  double h(double height) => height * heightScale;

  /// Scale a text size or padding value dynamically based on screen width.
  double sp(double size) => size * widthScale;

  // Breakpoints
  /// True if the screen is a mobile screen.
  bool get isMobile => screenWidth < 600;

  /// True if the screen is a tablet screen.
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// True if the screen is a desktop screen.
  bool get isDesktop => screenWidth >= 1024;
}
