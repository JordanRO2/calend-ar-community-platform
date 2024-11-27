// frontend/lib/presentation/widgets/common/common_responsive_breakpoints.dart

import 'package:flutter/material.dart';

class CommonResponsiveBreakpoints {
  static const double mobileMaxWidth = 800;

  static bool isMobile(double width) => width <= mobileMaxWidth;
  static bool isWeb(double width) => width > mobileMaxWidth;
}

/// Extensión para facilitar el acceso a los breakpoints
extension CommonResponsiveExtension on BuildContext {
  bool get isMobile =>
      CommonResponsiveBreakpoints.isMobile(MediaQuery.of(this).size.width);

  bool get isWeb =>
      CommonResponsiveBreakpoints.isWeb(MediaQuery.of(this).size.width);
}
