import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Utility class for optimizing images with caching and compression
class ImageOptimizer {
  static final Map<String, Uint8List> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50; // Maximum items in memory cache
  static const int _maxImageSize = 1024; // Maximum width/height for compressed images
  static const int _compressionQuality = 85; // JPEG compression quality (0-100)
  
  /// Get optimized image with caching
  static Future<Uint8List?> getOptimizedImage(String imagePath, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
    bool useCache = true,
  }) async {
    final cacheKey = _generateCacheKey(imagePath, maxWidth, maxHeight, quality);
    
    // Check memory cache first
    if (useCache && _memoryCache.containsKey(cacheKey)) {
      debugPrint('ImageOptimizer: Loading from memory cache: $imagePath');
      return _memoryCache[cacheKey];
    }
    
    // Check disk cache
    if (useCache) {
      final cachedData = await _loadFromDiskCache(cacheKey);
      if (cachedData != null) {
        debugPrint('ImageOptimizer: Loading from disk cache: $imagePath');
        _addToMemoryCache(cacheKey, cachedData);
        return cachedData;
      }
    }
    
    // Load and optimize image
    Uint8List? optimizedData;
    
    try {
      if (imagePath.startsWith('assets/')) {
        // Load from assets
        final byteData = await rootBundle.load(imagePath);
        optimizedData = await _optimizeImageData(
          byteData.buffer.asUint8List(),
          maxWidth: maxWidth ?? _maxImageSize,
          maxHeight: maxHeight ?? _maxImageSize,
          quality: quality ?? _compressionQuality,
        );
      } else if (imagePath.startsWith('http')) {
        // Load from network (implement if needed)
        debugPrint('ImageOptimizer: Network images not implemented yet');
        return null;
      } else {
        // Load from file system
        final file = File(imagePath);
        if (await file.exists()) {
          final imageData = await file.readAsBytes();
          optimizedData = await _optimizeImageData(
            imageData,
            maxWidth: maxWidth ?? _maxImageSize,
            maxHeight: maxHeight ?? _maxImageSize,
            quality: quality ?? _compressionQuality,
          );
        }
      }
      
      if (optimizedData != null && useCache) {
        // Save to caches
        _addToMemoryCache(cacheKey, optimizedData);
        await _saveToDiskCache(cacheKey, optimizedData);
      }
      
      return optimizedData;
    } catch (e) {
      debugPrint('ImageOptimizer: Error optimizing image $imagePath: $e');
      return null;
    }
  }
  
  /// Optimize image data by resizing and compressing
  static Future<Uint8List?> _optimizeImageData(
    Uint8List imageData, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      // Decode image
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Calculate new dimensions
      final originalWidth = image.width;
      final originalHeight = image.height;
      
      if (originalWidth <= maxWidth && originalHeight <= maxHeight) {
        // Image is already small enough
        return imageData;
      }
      
      final aspectRatio = originalWidth / originalHeight;
      int newWidth, newHeight;
      
      if (aspectRatio > 1) {
        // Landscape
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        // Portrait or square
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }
      
      // Create recorder for resized image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw resized image
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        Paint(),
      );
      
      // Convert to image
      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(newWidth, newHeight);
      
      // Convert to bytes
      final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      
      // Clean up
      image.dispose();
      resizedImage.dispose();
      picture.dispose();
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ImageOptimizer: Error in _optimizeImageData: $e');
      return null;
    }
  }
  
  /// Generate cache key for image
  static String _generateCacheKey(String imagePath, int? maxWidth, int? maxHeight, int? quality) {
    final key = '$imagePath-${maxWidth ?? _maxImageSize}-${maxHeight ?? _maxImageSize}-${quality ?? _compressionQuality}';
    return md5.convert(utf8.encode(key)).toString();
  }
  
  /// Add image to memory cache with size management
  static void _addToMemoryCache(String key, Uint8List data) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // Remove oldest entry
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
    }
    _memoryCache[key] = data;
  }
  
  /// Load image from disk cache
  static Future<Uint8List?> _loadFromDiskCache(String cacheKey) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/$cacheKey.cache');
      
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('ImageOptimizer: Error loading from disk cache: $e');
    }
    return null;
  }
  
  /// Save image to disk cache
  static Future<void> _saveToDiskCache(String cacheKey, Uint8List data) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/$cacheKey.cache');
      await cacheFile.writeAsBytes(data);
    } catch (e) {
      debugPrint('ImageOptimizer: Error saving to disk cache: $e');
    }
  }
  
  /// Get cache directory
  static Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/image_cache');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }
  
  /// Clear all caches
  static Future<void> clearCache() async {
    // Clear memory cache
    _memoryCache.clear();
    
    // Clear disk cache
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      debugPrint('ImageOptimizer: Cache cleared successfully');
    } catch (e) {
      debugPrint('ImageOptimizer: Error clearing cache: $e');
    }
  }
  
  /// Get cache size information
  static Future<Map<String, dynamic>> getCacheInfo() async {
    int memoryItems = _memoryCache.length;
    int memorySize = _memoryCache.values.fold(0, (sum, data) => sum + data.length);
    
    int diskItems = 0;
    int diskSize = 0;
    
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        diskItems = files.length;
        
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            diskSize += stat.size;
          }
        }
      }
    } catch (e) {
      debugPrint('ImageOptimizer: Error getting cache info: $e');
    }
    
    return {
      'memoryItems': memoryItems,
      'memorySize': memorySize,
      'diskItems': diskItems,
      'diskSize': diskSize,
      'memorySizeMB': (memorySize / (1024 * 1024)).toStringAsFixed(2),
      'diskSizeMB': (diskSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}

/// Optimized image widget with caching
class OptimizedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? maxWidth;
  final int? maxHeight;
  final int? quality;
  final bool useCache;
  
  const OptimizedImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.maxWidth,
    this.maxHeight,
    this.quality,
    this.useCache = true,
  }) : super(key: key);
  
  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  Future<void> _loadImage() async {
    try {
      final data = await ImageOptimizer.getOptimizedImage(
        widget.imagePath,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        quality: widget.quality,
        useCache: widget.useCache,
      );
      
      if (mounted) {
        setState(() {
          _imageData = data;
          _isLoading = false;
          _hasError = data == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.withOpacity(0.1),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }
    
    if (_hasError || _imageData == null) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.withOpacity(0.1),
            child: const Icon(Icons.error, color: Colors.grey),
          );
    }
    
    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}