class UsageStats {
  final int tokensUsed;
  final int messagesCount;
  final int hotkeysRegistered;
  final DateTime lastUpdated;

  UsageStats({
    this.tokensUsed = 0,
    this.messagesCount = 0,
    this.hotkeysRegistered = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  UsageStats copyWith({
    int? tokensUsed,
    int? messagesCount,
    int? hotkeysRegistered,
    DateTime? lastUpdated,
  }) {
    return UsageStats(
      tokensUsed: tokensUsed ?? this.tokensUsed,
      messagesCount: messagesCount ?? this.messagesCount,
      hotkeysRegistered: hotkeysRegistered ?? this.hotkeysRegistered,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokensUsed': tokensUsed,
      'messagesCount': messagesCount,
      'hotkeysRegistered': hotkeysRegistered,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      tokensUsed: json['tokensUsed'] as int? ?? 0,
      messagesCount: json['messagesCount'] as int? ?? 0,
      hotkeysRegistered: json['hotkeysRegistered'] as int? ?? 0,
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'] as String)
              : DateTime.now(),
    );
  }
}
