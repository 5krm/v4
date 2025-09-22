import 'package:flutter/material.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGradient;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final bool enabled;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGradient = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isOutlined || !isGradient
            ? null
            : (enabled ? MyColor.primaryGradient : null),
        color: isOutlined
            ? Colors.transparent
            : (!isGradient
                ? (backgroundColor ?? MyColor.primary)
                : (enabled ? null : MyColor.textSecondary)),
        border:
            isOutlined ? Border.all(color: MyColor.primary, width: 2) : null,
        boxShadow: !isOutlined && enabled
            ? [
                BoxShadow(
                  color: MyColor.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOutlined ? MyColor.primary : MyColor.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isOutlined
                              ? MyColor.primary
                              : (textColor ?? MyColor.white),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: outfitSemiBold.copyWith(
                          color: isOutlined
                              ? MyColor.primary
                              : (textColor ?? MyColor.white),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isGlass;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isGlass ? MyColor.glassBg : (backgroundColor ?? MyColor.cardBg),
        borderRadius: BorderRadius.circular(size / 4),
        border:
            isGlass ? Border.all(color: MyColor.glassBorder, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 4),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? MyColor.textPrimary,
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
