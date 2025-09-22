class SmartServerSettings {
  final String id;
  final String userId;
  final String optimizationMode;
  final bool autoFailover;
  final bool learningEnabled;
  final Map<String, double> scoringWeights;
  final Map<String, double> performanceThresholds;
  final Map<String, dynamic> userPreferences;
  final Map<String, dynamic> learningData;
  final Map<String, dynamic> statistics;
  final DateTime? lastRecommendationAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SmartServerSettings({
    this.id = '',
    this.userId = '',
    this.optimizationMode = 'balanced',
    this.autoFailover = true,
    this.learningEnabled = true,
    this.scoringWeights = const {
      'speed': 0.3,
      'latency': 0.25,
      'reliability': 0.2,
      'load': 0.15,
      'location': 0.1,
    },
    this.performanceThresholds = const {
      'min_speed_mbps': 10.0,
      'max_latency_ms': 100.0,
      'min_uptime_percent': 99.0,
      'max_load_percent': 80.0,
    },
    this.userPreferences = const {},
    this.learningData = const {},
    this.statistics = const {},
    this.lastRecommendationAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory SmartServerSettings.fromJson(Map<String, dynamic> json) {
    return SmartServerSettings(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      optimizationMode: json['optimization_mode'] ?? 'balanced',
      autoFailover: json['auto_failover'] ?? true,
      learningEnabled: json['learning_enabled'] ?? true,
      scoringWeights: Map<String, double>.from(json['scoring_weights'] ?? {}),
      performanceThresholds: Map<String, double>.from(json['performance_thresholds'] ?? {}),
      userPreferences: Map<String, dynamic>.from(json['user_preferences'] ?? {}),
      learningData: Map<String, dynamic>.from(json['learning_data'] ?? {}),
      statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
      lastRecommendationAt: json['last_recommendation_at'] != null
          ? DateTime.parse(json['last_recommendation_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'optimization_mode': optimizationMode,
      'auto_failover': autoFailover,
      'learning_enabled': learningEnabled,
      'scoring_weights': scoringWeights,
      'performance_thresholds': performanceThresholds,
      'user_preferences': userPreferences,
      'learning_data': learningData,
      'statistics': statistics,
      'last_recommendation_at': lastRecommendationAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SmartServerSettings copyWith({
    String? id,
    String? userId,
    String? optimizationMode,
    bool? autoFailover,
    bool? learningEnabled,
    Map<String, double>? scoringWeights,
    Map<String, double>? performanceThresholds,
    Map<String, dynamic>? userPreferences,
    Map<String, dynamic>? learningData,
    Map<String, dynamic>? statistics,
    DateTime? lastRecommendationAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SmartServerSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      optimizationMode: optimizationMode ?? this.optimizationMode,
      autoFailover: autoFailover ?? this.autoFailover,
      learningEnabled: learningEnabled ?? this.learningEnabled,
      scoringWeights: scoringWeights ?? this.scoringWeights,
      performanceThresholds: performanceThresholds ?? this.performanceThresholds,
      userPreferences: userPreferences ?? this.userPreferences,
      learningData: learningData ?? this.learningData,
      statistics: statistics ?? this.statistics,
      lastRecommendationAt: lastRecommendationAt ?? this.lastRecommendationAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ServerRecommendation {
  final String id;
  final String smartSelectionId;
  final String serverId;
  final String serverLocation;
  final String serverCountry;
  final String? serverCity;
  final String serverProtocol;
  final double recommendationScore;
  final Map<String, dynamic> factors;
  final Map<String, dynamic> weightsUsed;
  final String optimizationMode;
  final Map<String, dynamic>? userLocation;
  final String? userIp;
  final Map<String, dynamic>? connectionContext;
  final DateTime? recommendedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;
  final int? connectionDuration;
  final bool wasSuccessful;
  final String? failureReason;
  final Map<String, dynamic>? performanceMetrics;
  final double? userFeedbackRating;
  final bool autoSelected;
  final bool fallbackRecommendation;
  final int recommendationRank;
  final List<String>? alternativeServers;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServerRecommendation({
    required this.id,
    required this.smartSelectionId,
    required this.serverId,
    required this.serverLocation,
    required this.serverCountry,
    this.serverCity,
    this.serverProtocol = 'auto',
    this.recommendationScore = 0.0,
    this.factors = const {},
    this.weightsUsed = const {},
    this.optimizationMode = 'balanced',
    this.userLocation,
    this.userIp,
    this.connectionContext,
    this.recommendedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.connectedAt,
    this.disconnectedAt,
    this.connectionDuration,
    this.wasSuccessful = false,
    this.failureReason,
    this.performanceMetrics,
    this.userFeedbackRating,
    this.autoSelected = false,
    this.fallbackRecommendation = false,
    this.recommendationRank = 1,
    this.alternativeServers,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ServerRecommendation.fromJson(Map<String, dynamic> json) {
    return ServerRecommendation(
      id: json['id']?.toString() ?? '',
      smartSelectionId: json['smart_selection_id']?.toString() ?? '',
      serverId: json['server_id']?.toString() ?? '',
      serverLocation: json['server_location'] ?? '',
      serverCountry: json['server_country'] ?? '',
      serverCity: json['server_city'],
      serverProtocol: json['server_protocol'] ?? 'auto',
      recommendationScore: (json['recommendation_score'] ?? 0.0).toDouble(),
      factors: Map<String, dynamic>.from(json['factors'] ?? {}),
      weightsUsed: Map<String, dynamic>.from(json['weights_used'] ?? {}),
      optimizationMode: json['optimization_mode'] ?? 'balanced',
      userLocation: json['user_location'] != null
          ? Map<String, dynamic>.from(json['user_location'])
          : null,
      userIp: json['user_ip'],
      connectionContext: json['connection_context'] != null
          ? Map<String, dynamic>.from(json['connection_context'])
          : null,
      recommendedAt: json['recommended_at'] != null
          ? DateTime.parse(json['recommended_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
      connectedAt: json['connected_at'] != null
          ? DateTime.parse(json['connected_at'])
          : null,
      disconnectedAt: json['disconnected_at'] != null
          ? DateTime.parse(json['disconnected_at'])
          : null,
      connectionDuration: json['connection_duration'],
      wasSuccessful: json['was_successful'] ?? false,
      failureReason: json['failure_reason'],
      performanceMetrics: json['performance_metrics'] != null
          ? Map<String, dynamic>.from(json['performance_metrics'])
          : null,
      userFeedbackRating: json['user_feedback_rating']?.toDouble(),
      autoSelected: json['auto_selected'] ?? false,
      fallbackRecommendation: json['fallback_recommendation'] ?? false,
      recommendationRank: json['recommendation_rank'] ?? 1,
      alternativeServers: json['alternative_servers'] != null
          ? List<String>.from(json['alternative_servers'])
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smart_selection_id': smartSelectionId,
      'server_id': serverId,
      'server_location': serverLocation,
      'server_country': serverCountry,
      'server_city': serverCity,
      'server_protocol': serverProtocol,
      'recommendation_score': recommendationScore,
      'factors': factors,
      'weights_used': weightsUsed,
      'optimization_mode': optimizationMode,
      'user_location': userLocation,
      'user_ip': userIp,
      'connection_context': connectionContext,
      'recommended_at': recommendedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'connected_at': connectedAt?.toIso8601String(),
      'disconnected_at': disconnectedAt?.toIso8601String(),
      'connection_duration': connectionDuration,
      'was_successful': wasSuccessful,
      'failure_reason': failureReason,
      'performance_metrics': performanceMetrics,
      'user_feedback_rating': userFeedbackRating,
      'auto_selected': autoSelected,
      'fallback_recommendation': fallbackRecommendation,
      'recommendation_rank': recommendationRank,
      'alternative_servers': alternativeServers,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ServerFeedback {
  final String id;
  final String smartSelectionId;
  final String? serverRecommendationId;
  final String serverId;
  final String userId;
  final String feedbackType;
  final double rating;
  final double connectionQuality;
  final double speedRating;
  final double stabilityRating;
  final double latencyRating;
  final double overallSatisfaction;
  final bool wouldRecommend;
  final List<String>? connectionIssues;
  final List<String>? performanceIssues;
  final List<String>? featureIssues;
  final List<String>? positiveAspects;
  final List<String>? improvementSuggestions;
  final Map<String, dynamic>? connectionContext;
  final int? usageDuration;
  final int? dataTransferred;
  final String? disconnectReason;
  final Map<String, dynamic>? technicalDetails;
  final Map<String, dynamic>? userLocation;
  final Map<String, dynamic>? deviceInfo;
  final String? appVersion;
  final String? feedbackText;
  final List<String>? tags;
  final bool isVerified;
  final String? verificationMethod;
  final DateTime? submittedAt;
  final DateTime? processedAt;
  final double weight;
  final double impactScore;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServerFeedback({
    required this.id,
    required this.smartSelectionId,
    this.serverRecommendationId,
    required this.serverId,
    required this.userId,
    this.feedbackType = 'general',
    this.rating = 0.0,
    this.connectionQuality = 0.0,
    this.speedRating = 0.0,
    this.stabilityRating = 0.0,
    this.latencyRating = 0.0,
    this.overallSatisfaction = 0.0,
    this.wouldRecommend = false,
    this.connectionIssues,
    this.performanceIssues,
    this.featureIssues,
    this.positiveAspects,
    this.improvementSuggestions,
    this.connectionContext,
    this.usageDuration,
    this.dataTransferred,
    this.disconnectReason,
    this.technicalDetails,
    this.userLocation,
    this.deviceInfo,
    this.appVersion,
    this.feedbackText,
    this.tags,
    this.isVerified = false,
    this.verificationMethod,
    this.submittedAt,
    this.processedAt,
    this.weight = 1.0,
    this.impactScore = 0.0,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ServerFeedback.fromJson(Map<String, dynamic> json) {
    return ServerFeedback(
      id: json['id']?.toString() ?? '',
      smartSelectionId: json['smart_selection_id']?.toString() ?? '',
      serverRecommendationId: json['server_recommendation_id']?.toString(),
      serverId: json['server_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      feedbackType: json['feedback_type'] ?? 'general',
      rating: (json['rating'] ?? 0.0).toDouble(),
      connectionQuality: (json['connection_quality'] ?? 0.0).toDouble(),
      speedRating: (json['speed_rating'] ?? 0.0).toDouble(),
      stabilityRating: (json['stability_rating'] ?? 0.0).toDouble(),
      latencyRating: (json['latency_rating'] ?? 0.0).toDouble(),
      overallSatisfaction: (json['overall_satisfaction'] ?? 0.0).toDouble(),
      wouldRecommend: json['would_recommend'] ?? false,
      connectionIssues: json['connection_issues'] != null
          ? List<String>.from(json['connection_issues'])
          : null,
      performanceIssues: json['performance_issues'] != null
          ? List<String>.from(json['performance_issues'])
          : null,
      featureIssues: json['feature_issues'] != null
          ? List<String>.from(json['feature_issues'])
          : null,
      positiveAspects: json['positive_aspects'] != null
          ? List<String>.from(json['positive_aspects'])
          : null,
      improvementSuggestions: json['improvement_suggestions'] != null
          ? List<String>.from(json['improvement_suggestions'])
          : null,
      connectionContext: json['connection_context'] != null
          ? Map<String, dynamic>.from(json['connection_context'])
          : null,
      usageDuration: json['usage_duration'],
      dataTransferred: json['data_transferred'],
      disconnectReason: json['disconnect_reason'],
      technicalDetails: json['technical_details'] != null
          ? Map<String, dynamic>.from(json['technical_details'])
          : null,
      userLocation: json['user_location'] != null
          ? Map<String, dynamic>.from(json['user_location'])
          : null,
      deviceInfo: json['device_info'] != null
          ? Map<String, dynamic>.from(json['device_info'])
          : null,
      appVersion: json['app_version'],
      feedbackText: json['feedback_text'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isVerified: json['is_verified'] ?? false,
      verificationMethod: json['verification_method'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      weight: (json['weight'] ?? 1.0).toDouble(),
      impactScore: (json['impact_score'] ?? 0.0).toDouble(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smart_selection_id': smartSelectionId,
      'server_recommendation_id': serverRecommendationId,
      'server_id': serverId,
      'user_id': userId,
      'feedback_type': feedbackType,
      'rating': rating,
      'connection_quality': connectionQuality,
      'speed_rating': speedRating,
      'stability_rating': stabilityRating,
      'latency_rating': latencyRating,
      'overall_satisfaction': overallSatisfaction,
      'would_recommend': wouldRecommend,
      'connection_issues': connectionIssues,
      'performance_issues': performanceIssues,
      'feature_issues': featureIssues,
      'positive_aspects': positiveAspects,
      'improvement_suggestions': improvementSuggestions,
      'connection_context': connectionContext,
      'usage_duration': usageDuration,
      'data_transferred': dataTransferred,
      'disconnect_reason': disconnectReason,
      'technical_details': technicalDetails,
      'user_location': userLocation,
      'device_info': deviceInfo,
      'app_version': appVersion,
      'feedback_text': feedbackText,
      'tags': tags,
      'is_verified': isVerified,
      'verification_method': verificationMethod,
      'submitted_at': submittedAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'weight': weight,
      'impact_score': impactScore,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ServerAnalytics {
  final int totalRecommendations;
  final int successfulConnections;
  final double averageScore;
  final double successRate;
  final Map<String, int> recommendationsByCountry;
  final Map<String, double> averageScoresByMode;
  final Map<String, int> feedbackCounts;
  final Map<String, dynamic> performanceMetrics;
  final List<Map<String, dynamic>> topServers;
  final List<Map<String, dynamic>> recentActivity;
  final DateTime lastUpdated;

  ServerAnalytics({
    this.totalRecommendations = 0,
    this.successfulConnections = 0,
    this.averageScore = 0.0,
    this.successRate = 0.0,
    this.recommendationsByCountry = const {},
    this.averageScoresByMode = const {},
    this.feedbackCounts = const {},
    this.performanceMetrics = const {},
    this.topServers = const [],
    this.recentActivity = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory ServerAnalytics.fromJson(Map<String, dynamic> json) {
    return ServerAnalytics(
      totalRecommendations: json['total_recommendations'] ?? 0,
      successfulConnections: json['successful_connections'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      recommendationsByCountry: Map<String, int>.from(json['recommendations_by_country'] ?? {}),
      averageScoresByMode: Map<String, double>.from(json['average_scores_by_mode'] ?? {}),
      feedbackCounts: Map<String, int>.from(json['feedback_counts'] ?? {}),
      performanceMetrics: Map<String, dynamic>.from(json['performance_metrics'] ?? {}),
      topServers: List<Map<String, dynamic>>.from(json['top_servers'] ?? []),
      recentActivity: List<Map<String, dynamic>>.from(json['recent_activity'] ?? []),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_recommendations': totalRecommendations,
      'successful_connections': successfulConnections,
      'average_score': averageScore,
      'success_rate': successRate,
      'recommendations_by_country': recommendationsByCountry,
      'average_scores_by_mode': averageScoresByMode,
      'feedback_counts': feedbackCounts,
      'performance_metrics': performanceMetrics,
      'top_servers': topServers,
      'recent_activity': recentActivity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}