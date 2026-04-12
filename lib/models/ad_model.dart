import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum AdLevel {
  oddiy(
    'Oddiy',
    AppConstants.bronzeReward,
    Icons.play_circle_outline,
    Colors.green,
  ),
  orta("O'rta", AppConstants.silverReward, Icons.star_border, Colors.orange),
  jiddiy(
    'Jiddiy',
    AppConstants.goldReward,
    Icons.workspace_premium,
    Colors.red,
  );

  final String label;
  final double reward;
  final IconData icon;
  final Color color;

  const AdLevel(this.label, this.reward, this.icon, this.color);
}

class AdModel {
  final String id;
  final AdLevel level;
  final int durationSeconds;
  final bool isWatched;
  final DateTime? watchedAt;

  AdModel({
    required this.id,
    required this.level,
    this.durationSeconds = 30,
    this.isWatched = false,
    this.watchedAt,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? '',
      level: AdLevel.values.firstWhere(
        (e) => e.toString() == 'AdLevel.${json['level']}',
        orElse: () => AdLevel.oddiy,
      ),
      durationSeconds: json['durationSeconds'] ?? 30,
      isWatched: json['isWatched'] ?? false,
      watchedAt: json['watchedAt'] != null
          ? DateTime.parse(json['watchedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.toString().split('.').last,
      'durationSeconds': durationSeconds,
      'isWatched': isWatched,
      'watchedAt': watchedAt?.toIso8601String(),
    };
  }

  AdModel copyWith({
    String? id,
    AdLevel? level,
    int? durationSeconds,
    bool? isWatched,
    DateTime? watchedAt,
  }) {
    return AdModel(
      id: id ?? this.id,
      level: level ?? this.level,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isWatched: isWatched ?? this.isWatched,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }
}

class DailyStats {
  final DateTime date;
  int adsWatched;
  double earned;

  DailyStats({required this.date, this.adsWatched = 0, this.earned = 0.0});

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      adsWatched: json['adsWatched'] ?? 0,
      earned: (json['earned'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'adsWatched': adsWatched,
      'earned': earned,
    };
  }
}
