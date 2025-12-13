import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry outerPadding;

  const BlurredPanel({
    super.key,
    required this.child,
    this.outerPadding = const EdgeInsets.all(0), // Default: no outer padding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: outerPadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
