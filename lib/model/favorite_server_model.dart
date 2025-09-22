// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'server_model.dart';

// Favorite servers list model
FavoriteServersModel favoriteServersModelFromJson(String str) =>
    FavoriteServersModel.fromJson(json.decode(str));

String favoriteServersModelToJson(FavoriteServersModel data) =>
    json.encode(data.toJson());

class FavoriteServersModel {
  final String? status;
  final String? message;
  final List<Server>? data;

  FavoriteServersModel({
    this.status,
    this.message,
    this.data,
  });

  factory FavoriteServersModel.fromJson(Map<String, dynamic> json) =>
      FavoriteServersModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Server>.from(json["data"]!.map((x) => Server.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

// Add favorite server response model
AddFavoriteServerModel addFavoriteServerModelFromJson(String str) =>
    AddFavoriteServerModel.fromJson(json.decode(str));

String addFavoriteServerModelToJson(AddFavoriteServerModel data) =>
    json.encode(data.toJson());

class AddFavoriteServerModel {
  final String? status;
  final String? message;
  final FavoriteServerData? data;

  AddFavoriteServerModel({
    this.status,
    this.message,
    this.data,
  });

  factory AddFavoriteServerModel.fromJson(Map<String, dynamic> json) =>
      AddFavoriteServerModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : FavoriteServerData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class FavoriteServerData {
  final int? id;
  final int? userId;
  final int? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FavoriteServerData({
    this.id,
    this.userId,
    this.serverId,
    this.createdAt,
    this.updatedAt,
  });

  factory FavoriteServerData.fromJson(Map<String, dynamic> json) =>
      FavoriteServerData(
        id: json["id"],
        userId: json["user_id"],
        serverId: json["server_id"],
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
        "server_id": serverId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

// Is favorite response model
IsFavoriteModel isFavoriteModelFromJson(String str) =>
    IsFavoriteModel.fromJson(json.decode(str));

String isFavoriteModelToJson(IsFavoriteModel data) =>
    json.encode(data.toJson());

class IsFavoriteModel {
  final String? status;
  final String? message;
  final IsFavoriteData? data;

  IsFavoriteModel({
    this.status,
    this.message,
    this.data,
  });

  factory IsFavoriteModel.fromJson(Map<String, dynamic> json) =>
      IsFavoriteModel(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null ? null : IsFavoriteData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class IsFavoriteData {
  final bool? isFavorite;

  IsFavoriteData({
    this.isFavorite,
  });

  factory IsFavoriteData.fromJson(Map<String, dynamic> json) => IsFavoriteData(
        isFavorite: json["is_favorite"],
      );

  Map<String, dynamic> toJson() => {
        "is_favorite": isFavorite,
      };
}
