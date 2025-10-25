class Hotkey {
  final String id;
  final String key;
  final String modelId;
  final String modelName;
  final String action;
  final DateTime createdAt;

  Hotkey({
    required this.id,
    required this.key,
    required this.modelId,
    required this.modelName,
    required this.action,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Hotkey copyWith({
    String? id,
    String? key,
    String? modelId,
    String? modelName,
    String? action,
    DateTime? createdAt,
  }) {
    return Hotkey(
      id: id ?? this.id,
      key: key ?? this.key,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'modelId': modelId,
      'modelName': modelName,
      'action': action,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Hotkey.fromJson(Map<String, dynamic> json) {
    return Hotkey(
      id: json['id'] as String,
      key: json['key'] as String,
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      action: json['action'] as String,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}
