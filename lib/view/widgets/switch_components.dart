import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/switch_colors.dart';
import '../../utils/my_font.dart';

/// Switch VPN Modern Card Component
class SwitchCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasGlow;
  final Color? glowColor;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const SwitchCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.hasGlow = false,
    this.glowColor,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? SwitchColors.switchCardGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: SwitchColors.glassLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SwitchColors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (hasGlow && glowColor != null)
            SwitchColors.getGlow(glowColor!, blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Material(
        color: SwitchColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: SwitchColors.switchBlue.withOpacity(0.1),
          highlightColor: SwitchColors.switchBlue.withOpacity(0.05),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Switch VPN Connection Button
class SwitchConnectionButton extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback? onTap;
  final double size;

  const SwitchConnectionButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    this.onTap,
    this.size = 200,
  });

  @override
  State<SwitchConnectionButton> createState() => _SwitchConnectionButtonState();
}

class _SwitchConnectionButtonState extends State<SwitchConnectionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.isConnecting) {
      _rotationController.repeat();
    } else if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SwitchConnectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isConnecting && !oldWidget.isConnecting) {
      _pulseController.stop();
      _rotationController.repeat();
    } else if (widget.isConnected && !oldWidget.isConnected) {
      _rotationController.stop();
      _pulseController.repeat(reverse: true);
    } else if (!widget.isConnecting && !widget.isConnected) {
      _pulseController.stop();
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: widget.isConnecting ? _rotationController : _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isConnecting ? 1.0 : _pulseAnimation.value,
            child: Transform.rotate(
              angle: widget.isConnecting ? _rotationAnimation.value : 0,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isConnected
                      ? SwitchColors.switchSuccessGradient
                      : SwitchColors.switchConnectionGradient,
                  boxShadow: [
                    SwitchColors.getGlow(
                      widget.isConnected
                          ? SwitchColors.switchGreen
                          : SwitchColors.switchBlue,
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: SwitchColors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SwitchColors.switchDark.withOpacity(0.9),
                    border: Border.all(
                      color: SwitchColors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: widget.isConnecting
                      ? Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: SwitchColors.switchBlue,
                              strokeWidth: 4,
                              backgroundColor:
                                  SwitchColors.white.withOpacity(0.2),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isConnected
                                  ? Icons.power_off_rounded
                                  : Icons.power_settings_new_rounded,
                              color: SwitchColors.white,
                              size: widget.size * 0.25,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isConnected
                                  ? 'DISCONNECT'
                                  : 'TAP TO CONNECT',
                              style: outfitBold.copyWith(
                                color: SwitchColors.white,
                                fontSize: widget.size * 0.08,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isConnected ? 'Connected' : 'Disconnected',
                              style: outfitMedium.copyWith(
                                color: SwitchColors.white.withOpacity(0.7),
                                fontSize: widget.size * 0.06,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Switch VPN Server Selection Card
class SwitchServerCard extends StatelessWidget {
  final String? countryName;
  final String? flagAsset;
  final String? ping;
  final bool isSelected;
  final bool isPremium;
  final VoidCallback? onTap;

  const SwitchServerCard({
    super.key,
    this.countryName,
    this.flagAsset,
    this.ping,
    this.isSelected = false,
    this.isPremium = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchCard(
      hasGlow: isSelected,
      glowColor: isSelected ? SwitchColors.switchBlue : null,
      onTap: onTap,
      child: Row(
        children: [
          // Flag
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SwitchColors.switchDarkSurface,
            ),
            child: flagAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      flagAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.flag,
                          color: SwitchColors.switchBlue,
                          size: 20,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.public,
                    color: SwitchColors.switchBlue,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 16),

          // Country Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countryName ?? 'Auto',
                  style: outfitSemiBold.copyWith(
                    color: SwitchColors.switchTextPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ping ?? '0'}ms',
                  style: outfitMedium.copyWith(
                    color: SwitchColors.switchTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicators
          Row(
            children: [
              // Ping Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPingColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPingLabel(),
                  style: outfitMedium.copyWith(
                    color: _getPingColor(),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Premium Badge
              if (isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: SwitchColors.switchButtonGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRO',
                    style: outfitBold.copyWith(
                      color: SwitchColors.white,
                      fontSize: 8,
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // Selection Indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: SwitchColors.switchGreen,
                  size: 20,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: SwitchColors.switchTextTertiary,
                  size: 20,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPingColor() {
    final pingValue = int.tryParse(ping?.replaceAll('ms', '') ?? '0') ?? 0;
    if (pingValue <= 50) return SwitchColors.switchGreen;
    if (pingValue <= 100) return SwitchColors.switchYellow;
    return SwitchColors.switchRed;
  }

  String _getPingLabel() {
    final pingValue = int.tryParse(ping?.replaceAll('ms', '') ?? '0') ?? 0;
    if (pingValue <= 50) return 'Fast';
    if (pingValue <= 100) return 'Good';
    return 'Slow';
  }
}

/// Switch VPN Status Indicator
class SwitchStatusIndicator extends StatelessWidget {
  final bool isConnected;
  final String title;
  final String subtitle;
  final IconData icon;

  const SwitchStatusIndicator({
    super.key,
    required this.isConnected,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchCard(
      hasGlow: isConnected,
      glowColor: isConnected ? SwitchColors.switchGreen : null,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isConnected
                  ? SwitchColors.switchSuccessGradient
                  : LinearGradient(
                      colors: [
                        SwitchColors.switchRed.withOpacity(0.3),
                        SwitchColors.switchRed.withOpacity(0.1),
                      ],
                    ),
            ),
            child: Icon(
              icon,
              color: isConnected ? SwitchColors.white : SwitchColors.switchRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: outfitBold.copyWith(
                    color: isConnected
                        ? SwitchColors.switchGreen
                        : SwitchColors.switchRed,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: outfitMedium.copyWith(
                    color: SwitchColors.switchTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Switch VPN Modern Button
class SwitchButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final Gradient? gradient;
  final Color? textColor;

  const SwitchButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 52,
    this.gradient,
    this.textColor,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined
                    ? null
                    : (widget.gradient ?? SwitchColors.switchButtonGradient),
                borderRadius: BorderRadius.circular(16),
                border: widget.isOutlined
                    ? Border.all(color: SwitchColors.switchBlue, width: 2)
                    : null,
                boxShadow: widget.isOutlined
                    ? null
                    : [
                        SwitchColors.getGlow(
                          SwitchColors.switchBlue,
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Material(
                color: SwitchColors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: widget.textColor ?? SwitchColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isOutlined
                                  ? SwitchColors.switchBlue
                                  : (widget.textColor ?? SwitchColors.white),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: outfitSemiBold.copyWith(
                              color: widget.isOutlined
                                  ? SwitchColors.switchBlue
                                  : (widget.textColor ?? SwitchColors.white),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
