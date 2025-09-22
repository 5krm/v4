import 'dart:async';
import 'package:flutter/material.dart';

/// Utility class for debouncing function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  /// Execute function after delay, canceling previous calls
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Check if debouncer is active
  bool get isActive => _timer?.isActive ?? false;
  
  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttle utility for limiting function execution frequency
class Throttler {
  final Duration duration;
  DateTime? _lastExecution;
  
  Throttler({required this.duration});
  
  /// Execute function only if enough time has passed since last execution
  bool call(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecution == null || 
        now.difference(_lastExecution!).compareTo(duration) >= 0) {
      _lastExecution = now;
      action();
      return true;
    }
    
    return false;
  }
  
  /// Reset throttler state
  void reset() {
    _lastExecution = null;
  }
  
  /// Check if throttler is ready for next execution
  bool get isReady {
    if (_lastExecution == null) return true;
    return DateTime.now().difference(_lastExecution!).compareTo(duration) >= 0;
  }
}

/// API call debouncer specifically for network requests
class ApiDebouncer {
  final Map<String, Debouncer> _debouncers = {};
  final Duration defaultDelay;
  
  ApiDebouncer({this.defaultDelay = const Duration(milliseconds: 500)});
  
  /// Debounce API call by endpoint
  void debounceApiCall(String endpoint, Future<void> Function() apiCall, {
    Duration? customDelay,
  }) {
    final delay = customDelay ?? defaultDelay;
    
    if (!_debouncers.containsKey(endpoint)) {
      _debouncers[endpoint] = Debouncer(delay: delay);
    }
    
    _debouncers[endpoint]!.call(() async {
      try {
        await apiCall();
      } catch (e) {
        debugPrint('ApiDebouncer: Error in API call for $endpoint: $e');
      }
    });
  }
  
  /// Cancel specific endpoint debouncer
  void cancelEndpoint(String endpoint) {
    _debouncers[endpoint]?.cancel();
  }
  
  /// Cancel all pending API calls
  void cancelAll() {
    for (final debouncer in _debouncers.values) {
      debouncer.cancel();
    }
  }
  
  /// Dispose all debouncers
  void dispose() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
  }
}

/// Search debouncer for text input fields
class SearchDebouncer {
  final Debouncer _debouncer;
  String _lastQuery = '';
  
  SearchDebouncer({Duration delay = const Duration(milliseconds: 300)})
      : _debouncer = Debouncer(delay: delay);
  
  /// Debounce search query
  void search(String query, Function(String) onSearch) {
    if (query == _lastQuery) return;
    
    _lastQuery = query;
    _debouncer.call(() => onSearch(query));
  }
  
  /// Cancel pending search
  void cancel() {
    _debouncer.cancel();
  }
  
  /// Dispose search debouncer
  void dispose() {
    _debouncer.dispose();
  }
}

/// Button debouncer to prevent rapid taps
class ButtonDebouncer {
  final Duration delay;
  DateTime? _lastTap;
  
  ButtonDebouncer({this.delay = const Duration(milliseconds: 500)});
  
  /// Execute action only if enough time has passed since last tap
  bool onTap(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastTap == null || 
        now.difference(_lastTap!).compareTo(delay) >= 0) {
      _lastTap = now;
      action();
      return true;
    }
    
    debugPrint('ButtonDebouncer: Tap ignored - too frequent');
    return false;
  }
  
  /// Reset debouncer state
  void reset() {
    _lastTap = null;
  }
}

/// Mixin for adding debouncing capabilities to controllers
mixin DebounceMixin {
  final Map<String, Debouncer> _debouncers = {};
  final Map<String, Throttler> _throttlers = {};
  
  /// Create or get debouncer for specific key
  Debouncer getDebouncer(String key, {Duration delay = const Duration(milliseconds: 500)}) {
    return _debouncers.putIfAbsent(key, () => Debouncer(delay: delay));
  }
  
  /// Create or get throttler for specific key
  Throttler getThrottler(String key, {Duration duration = const Duration(seconds: 1)}) {
    return _throttlers.putIfAbsent(key, () => Throttler(duration: duration));
  }
  
  /// Debounce function call
  void debounce(String key, VoidCallback action, {Duration? delay}) {
    getDebouncer(key, delay: delay ?? const Duration(milliseconds: 500)).call(action);
  }
  
  /// Throttle function call
  bool throttle(String key, VoidCallback action, {Duration? duration}) {
    return getThrottler(key, duration: duration ?? const Duration(seconds: 1)).call(action);
  }
  
  /// Cancel specific debouncer
  void cancelDebouncer(String key) {
    _debouncers[key]?.cancel();
  }
  
  /// Cancel all debouncers and throttlers
  void cancelAllDebouncers() {
    for (final debouncer in _debouncers.values) {
      debouncer.cancel();
    }
    for (final throttler in _throttlers.values) {
      throttler.reset();
    }
  }
  
  /// Dispose all debouncers and throttlers
  void disposeDebouncing() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
    _throttlers.clear();
  }
}

/// Debounced text field widget
class DebouncedTextField extends StatefulWidget {
  final String? hintText;
  final Function(String) onChanged;
  final Duration debounceDelay;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final bool enabled;
  
  const DebouncedTextField({
    Key? key,
    required this.onChanged,
    this.hintText,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.controller,
    this.decoration,
    this.style,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  late final SearchDebouncer _searchDebouncer;
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _searchDebouncer = SearchDebouncer(delay: widget.debounceDelay);
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void dispose() {
    _searchDebouncer.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      style: widget.style,
      maxLines: widget.maxLines,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        _searchDebouncer.search(value, widget.onChanged);
      },
    );
  }
}

/// Debounced button widget
class DebouncedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration debounceDelay;
  final ButtonStyle? style;
  
  const DebouncedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.debounceDelay = const Duration(milliseconds: 500),
    this.style,
  }) : super(key: key);
  
  @override
  State<DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  late final ButtonDebouncer _buttonDebouncer;
  
  @override
  void initState() {
    super.initState();
    _buttonDebouncer = ButtonDebouncer(delay: widget.debounceDelay);
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.style,
      onPressed: widget.onPressed == null ? null : () {
        _buttonDebouncer.onTap(widget.onPressed!);
      },
      child: widget.child,
    );
  }
}