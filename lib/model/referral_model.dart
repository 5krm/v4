// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

// Referral code model
ReferralCodeModel referralCodeModelFromJson(String str) =>
    ReferralCodeModel.fromJson(json.decode(str));

String referralCodeModelToJson(ReferralCodeModel data) =>
    json.encode(data.toJson());

class ReferralCodeModel {
  final String? status;
  final String? message;
  final ReferralCodeData? data;

  ReferralCodeModel({
    this.status,
    this.message,
    this.data,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) =>
      ReferralCodeModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ReferralCodeData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ReferralCodeData {
  final int? id;
  final int? userId;
  final String? code;
  final int? usageCount;
  final double? rewardAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReferralCodeData({
    this.id,
    this.userId,
    this.code,
    this.usageCount,
    this.rewardAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory ReferralCodeData.fromJson(Map<String, dynamic> json) =>
      ReferralCodeData(
        id: json["id"],
        userId: json["user_id"],
        code: json["code"],
        usageCount: json["usage_count"],
        rewardAmount: json["reward_amount"]?.toDouble(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "code": code,
        "usage_count": usageCount,
        "reward_amount": rewardAmount,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

// Referral stats model
ReferralStatsModel referralStatsModelFromJson(String str) =>
    ReferralStatsModel.fromJson(json.decode(str));

String referralStatsModelToJson(ReferralStatsModel data) =>
    json.encode(data.toJson());

class ReferralStatsModel {
  final String? status;
  final String? message;
  final ReferralStatsData? data;

  ReferralStatsModel({
    this.status,
    this.message,
    this.data,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) =>
      ReferralStatsModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ReferralStatsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ReferralStatsData {
  final String? referralCode;
  final int? totalReferrals;
  final double? totalEarnings;
  final double? pendingRewards;
  final double? claimedRewards;

  ReferralStatsData({
    this.referralCode,
    this.totalReferrals,
    this.totalEarnings,
    this.pendingRewards,
    this.claimedRewards,
  });

  factory ReferralStatsData.fromJson(Map<String, dynamic> json) =>
      ReferralStatsData(
        referralCode: json["referral_code"],
        totalReferrals: json["total_referrals"],
        totalEarnings: json["total_earnings"]?.toDouble(),
        pendingRewards: json["pending_rewards"]?.toDouble(),
        claimedRewards: json["claimed_rewards"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "referral_code": referralCode,
        "total_referrals": totalReferrals,
        "total_earnings": totalEarnings,
        "pending_rewards": pendingRewards,
        "claimed_rewards": claimedRewards,
      };
}

// Apply referral response model
ApplyReferralModel applyReferralModelFromJson(String str) =>
    ApplyReferralModel.fromJson(json.decode(str));

String applyReferralModelToJson(ApplyReferralModel data) =>
    json.encode(data.toJson());

class ApplyReferralModel {
  final String? status;
  final String? message;
  final ApplyReferralData? data;

  ApplyReferralModel({
    this.status,
    this.message,
    this.data,
  });

  factory ApplyReferralModel.fromJson(Map<String, dynamic> json) =>
      ApplyReferralModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ApplyReferralData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ApplyReferralData {
  final int? id;
  final int? referrerId;
  final int? referredUserId;
  final int? referralCodeId;
  final double? rewardAmount;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApplyReferralData({
    this.id,
    this.referrerId,
    this.referredUserId,
    this.referralCodeId,
    this.rewardAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ApplyReferralData.fromJson(Map<String, dynamic> json) =>
      ApplyReferralData(
        id: json["id"],
        referrerId: json["referrer_id"],
        referredUserId: json["referred_user_id"],
        referralCodeId: json["referral_code_id"],
        rewardAmount: json["reward_amount"]?.toDouble(),
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referrer_id": referrerId,
        "referred_user_id": referredUserId,
        "referral_code_id": referralCodeId,
        "reward_amount": rewardAmount,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
