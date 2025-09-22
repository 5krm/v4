import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A widget that lazy loads its content when it becomes visible
class LazyLoadingWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final double visibilityThreshold;
  final Duration? delay;
  final String? debugLabel;

  const LazyLoadingWidget({
    Key? key,
    required this.builder,
    this.placeholder,
    this.visibilityThreshold = 0.1,
    this.delay,
    this.debugLabel,
  }) : super(key: key);

  @override
  State<LazyLoadingWidget> createState() => _LazyLoadingWidgetState();
}

class _LazyLoadingWidgetState extends State<LazyLoadingWidget> {
  bool _isLoaded = false;
  bool _isVisible = false;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    // Pre-load if no visibility detection is needed
    if (widget.visibilityThreshold <= 0) {
      _loadWidget();
    }
  }

  void _loadWidget() {
    if (_isLoaded) return;
    
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted && _isVisible) {
          setState(() {
            _cachedWidget = widget.builder();
            _isLoaded = true;
          });
        }
      });
    } else {
      setState(() {
        _cachedWidget = widget.builder();
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visibilityThreshold <= 0) {
      return _cachedWidget ?? widget.builder();
    }

    return VisibilityDetector(
      key: Key(widget.debugLabel ?? 'lazy_widget_${widget.hashCode}'),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction >= widget.visibilityThreshold;
        if (isVisible && !_isVisible) {
          _isVisible = true;
          _loadWidget();
        }
      },
      child: _isLoaded
          ? _cachedWidget!
          : widget.placeholder ??
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _cachedWidget = null;
    super.dispose();
  }
}

/// A widget that lazy loads charts and heavy visualizations
class LazyChart extends StatelessWidget {
  final Widget Function() chartBuilder;
  final Widget? loadingWidget;
  final double height;
  final String? debugLabel;

  const LazyChart({
    Key? key,
    required this.chartBuilder,
    this.loadingWidget,
    this.height = 200,
    this.debugLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LazyLoadingWidget(
        builder: chartBuilder,
        placeholder: loadingWidget ??
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 8),
                    Text(
                      'Loading chart...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        visibilityThreshold: 0.2,
        delay: const Duration(milliseconds: 100),
        debugLabel: debugLabel ?? 'lazy_chart',
      ),
    );
  }
}

/// A widget that lazy loads list items for better performance
class LazyListItem extends StatelessWidget {
  final Widget Function() itemBuilder;
  final Widget? placeholder;
  final double? height;
  final EdgeInsets? margin;

  const LazyListItem({
    Key? key,
    required this.itemBuilder,
    this.placeholder,
    this.height,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      child: LazyLoadingWidget(
        builder: itemBuilder,
        placeholder: placeholder ??
            Container(
              height: height ?? 60,
              margin: margin,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
            ),
        visibilityThreshold: 0.1,
      ),
    );
  }
}

/// Performance optimized ListView with lazy loading
class PerformantListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformantListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      cacheExtent: 500, // Cache 500 pixels worth of items
      addAutomaticKeepAlives: false, // Don't keep items alive automatically
      addRepaintBoundaries: true, // Add repaint boundaries for better performance
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }
}