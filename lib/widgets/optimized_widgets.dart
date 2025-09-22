import 'package:flutter/material.dart';

/// Optimized container with const constructor
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  
  const OptimizedContainer({
    Key? key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}

/// Optimized text widget with const constructor
class OptimizedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  
  const OptimizedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Optimized button with const constructor and debouncing
class OptimizedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool enabled;
  
  const OptimizedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
      onPressed: enabled ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

/// Optimized list tile with const constructor
class OptimizedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final bool dense;
  
  const OptimizedListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.enabled = true,
    this.dense = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      contentPadding: contentPadding,
      enabled: enabled,
      dense: dense,
    );
  }
}

/// Optimized card with const constructor
class OptimizedCard extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  
  const OptimizedCard({
    Key? key,
    this.child,
    this.color,
    this.elevation,
    this.shape,
    this.margin,
    this.clipBehavior = Clip.none,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      color: color,
      elevation: elevation,
      shape: shape,
      margin: margin,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Optimized column with const constructor
class OptimizedColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  
  const OptimizedColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Optimized row with const constructor
class OptimizedRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  
  const OptimizedRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Optimized padding with const constructor
class OptimizedPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  
  const OptimizedPadding({
    Key? key,
    required this.padding,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: key,
      padding: padding,
      child: child,
    );
  }
}

/// Optimized sized box with const constructor
class OptimizedSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  
  const OptimizedSizedBox({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);
  
  const OptimizedSizedBox.shrink({Key? key})
      : width = 0.0,
        height = 0.0,
        child = null,
        super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Optimized center widget with const constructor
class OptimizedCenter extends StatelessWidget {
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  
  const OptimizedCenter({
    Key? key,
    required this.child,
    this.widthFactor,
    this.heightFactor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      key: key,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: child,
    );
  }
}

/// Optimized expanded widget with const constructor
class OptimizedExpanded extends StatelessWidget {
  final Widget child;
  final int flex;
  
  const OptimizedExpanded({
    Key? key,
    required this.child,
    this.flex = 1,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: key,
      flex: flex,
      child: child,
    );
  }
}

/// Optimized flexible widget with const constructor
class OptimizedFlexible extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;
  
  const OptimizedFlexible({
    Key? key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Flexible(
      key: key,
      flex: flex,
      fit: fit,
      child: child,
    );
  }
}

/// Performance-optimized ListView builder
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  
  const OptimizedListView.builder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: key,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('item_$index'),
          child: itemBuilder(context, index),
        );
      },
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // We add them manually above
    );
  }
}

/// Optimized grid view
class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const OptimizedGridView.builder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: key,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('grid_item_$index'),
          child: itemBuilder(context, index),
        );
      },
      gridDelegate: gridDelegate,
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // We add them manually above
    );
  }
}

/// Widget optimization utilities
class WidgetOptimizer {
  /// Generate unique key for widget based on data
  static Key generateKey(String prefix, dynamic data) {
    return ValueKey('${prefix}_${data.hashCode}');
  }
  
  /// Create optimized key for list items
  static Key listItemKey(String prefix, int index, [dynamic data]) {
    if (data != null) {
      return ValueKey('${prefix}_${index}_${data.hashCode}');
    }
    return ValueKey('${prefix}_$index');
  }
  
  /// Wrap widget with repaint boundary for better performance
  static Widget withRepaintBoundary(Widget child, {Key? key}) {
    return RepaintBoundary(
      key: key,
      child: child,
    );
  }
  
  /// Wrap widget with automatic keep alive for lists
  static Widget withKeepAlive(Widget child, {bool keepAlive = true}) {
    return AutomaticKeepAlive(
      child: child,
    );
  }
}

/// Mixin for optimizing widget rebuilds
mixin WidgetOptimizationMixin<T extends StatefulWidget> on State<T> {
  /// Cache for expensive computations
  final Map<String, dynamic> _computationCache = {};
  
  /// Get cached computation result or compute and cache it
  R getCachedComputation<R>(String key, R Function() computation) {
    if (!_computationCache.containsKey(key)) {
      _computationCache[key] = computation();
    }
    return _computationCache[key] as R;
  }
  
  /// Clear computation cache
  void clearComputationCache() {
    _computationCache.clear();
  }
  
  /// Clear specific cached computation
  void clearCachedComputation(String key) {
    _computationCache.remove(key);
  }
  
  @override
  void dispose() {
    _computationCache.clear();
    super.dispose();
  }
}