enum HotkeyActionType {
  rephrase,
  fixGrammar,
  summarize,
  expand,
  custom;

  String get displayName {
    switch (this) {
      case HotkeyActionType.rephrase:
        return 'Rephrase';
      case HotkeyActionType.fixGrammar:
        return 'Fix Grammar';
      case HotkeyActionType.summarize:
        return 'Summarize';
      case HotkeyActionType.expand:
        return 'Expand';
      case HotkeyActionType.custom:
        return 'Custom Prompt';
    }
  }
}

enum HotkeyStyle {
  professional,
  casual,
  concise,
  detailed;

  String get displayName {
    switch (this) {
      case HotkeyStyle.professional:
        return 'Professional';
      case HotkeyStyle.casual:
        return 'Casual';
      case HotkeyStyle.concise:
        return 'Concise';
      case HotkeyStyle.detailed:
        return 'Detailed';
    }
  }
}

class Hotkey {
  final String id;
  final String name;
  final String keyCombo;
  final String modelId;
  final String modelName;
  final HotkeyActionType actionType;
  final HotkeyStyle? style;
  final String? customPrompt;
  final bool isActive;
  final bool showNotification;
  final bool saveToHistory;
  final DateTime? lastUsed;
  final DateTime createdAt;

  Hotkey({
    required this.id,
    required this.name,
    required this.keyCombo,
    required this.modelId,
    required this.modelName,
    required this.actionType,
    this.style,
    this.customPrompt,
    this.isActive = true,
    this.showNotification = true,
    this.saveToHistory = true,
    this.lastUsed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Hotkey copyWith({
    String? id,
    String? name,
    String? keyCombo,
    String? modelId,
    String? modelName,
    HotkeyActionType? actionType,
    HotkeyStyle? style,
    String? customPrompt,
    bool? isActive,
    bool? showNotification,
    bool? saveToHistory,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return Hotkey(
      id: id ?? this.id,
      name: name ?? this.name,
      keyCombo: keyCombo ?? this.keyCombo,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      actionType: actionType ?? this.actionType,
      style: style ?? this.style,
      customPrompt: customPrompt ?? this.customPrompt,
      isActive: isActive ?? this.isActive,
      showNotification: showNotification ?? this.showNotification,
      saveToHistory: saveToHistory ?? this.saveToHistory,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keyCombo': keyCombo,
      'modelId': modelId,
      'modelName': modelName,
      'actionType': actionType.name,
      'style': style?.name,
      'customPrompt': customPrompt,
      'isActive': isActive,
      'showNotification': showNotification,
      'saveToHistory': saveToHistory,
      'lastUsed': lastUsed?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Hotkey.fromJson(Map<String, dynamic> json) {
    return Hotkey(
      id: json['id'] as String,
      name: json['name'] as String,
      keyCombo: json['keyCombo'] as String,
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      actionType: HotkeyActionType.values.firstWhere(
        (e) => e.name == json['actionType'],
        orElse: () => HotkeyActionType.rephrase,
      ),
      style:
          json['style'] != null
              ? HotkeyStyle.values.firstWhere(
                (e) => e.name == json['style'],
                orElse: () => HotkeyStyle.professional,
              )
              : null,
      customPrompt: json['customPrompt'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      showNotification: json['showNotification'] as bool? ?? true,
      saveToHistory: json['saveToHistory'] as bool? ?? true,
      lastUsed:
          json['lastUsed'] != null
              ? DateTime.parse(json['lastUsed'] as String)
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}
