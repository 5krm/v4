// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? blurRadius;
  final double? opacity;
  final Color? color;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.blurRadius,
    this.opacity,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final glassCard = Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(opacity ?? 0.1),
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blurRadius ?? 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: glassCard,
      );
    }

    return glassCard;
  }
}
