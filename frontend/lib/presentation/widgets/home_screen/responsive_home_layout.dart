// frontend/lib/presentation/widgets/home_screen/responsive_home_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/home_screen/mobile_home_layout.dart';
import 'package:frontend/presentation/widgets/home_screen/web_home_layout.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class ResponsiveHomeLayout extends StatelessWidget {
  const ResponsiveHomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(
              CommonResponsiveBreakpoints.isWeb(constraints.maxWidth)
                  ? 'web_layout'
                  : 'mobile_layout',
            ),
            child: CommonResponsiveBreakpoints.isWeb(constraints.maxWidth)
                ? const WebHomeLayout()
                : const MobileHomeLayout(),
          ),
        );
      },
    );
  }
}
