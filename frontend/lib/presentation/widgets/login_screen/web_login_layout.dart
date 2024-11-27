// frontend/lib/presentation/widgets/login_screen/web_login_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/login_screen/web_side_panel.dart';
import 'package:frontend/presentation/widgets/login_screen/login_form_container.dart';

class WebLoginLayout extends StatelessWidget {
  const WebLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: WebSidePanel(),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: const IntrinsicHeight(
                      child: LoginFormContainer(isWeb: true),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
