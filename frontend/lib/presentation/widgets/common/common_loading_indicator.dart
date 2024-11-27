import 'package:flutter/material.dart';

class CommonLoadingIndicator extends StatelessWidget {
  final double size;

  final Color? color;

  const CommonLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).colorScheme.secondary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      ),
    );
  }
}
