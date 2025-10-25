enum AppThemeMode { light, dark, neutral, ocean, sunset, forest }

enum ChatPersonaIcon {
  robot,
  brain,
  sparkles,
  star,
  rocket,
  lightbulb,
  graduation,
  heart,
  fire,
  diamond,
}

class AppSettings {
  final String? openRouterApiKey;
  final bool isDarkMode; // Keep for backward compatibility
  final AppThemeMode themeMode;
  final ChatPersonaIcon chatPersonaIcon;

  AppSettings({
    this.openRouterApiKey,
    this.isDarkMode = false,
    this.themeMode = AppThemeMode.light,
    this.chatPersonaIcon = ChatPersonaIcon.robot,
  });

  AppSettings copyWith({
    String? openRouterApiKey,
    bool? isDarkMode,
    AppThemeMode? themeMode,
    ChatPersonaIcon? chatPersonaIcon,
  }) {
    return AppSettings(
      openRouterApiKey: openRouterApiKey ?? this.openRouterApiKey,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeMode: themeMode ?? this.themeMode,
      chatPersonaIcon: chatPersonaIcon ?? this.chatPersonaIcon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openRouterApiKey': openRouterApiKey,
      'isDarkMode': isDarkMode,
      'themeMode': themeMode.name,
      'chatPersonaIcon': chatPersonaIcon.name,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      openRouterApiKey: json['openRouterApiKey'] as String?,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.light,
      ),
      chatPersonaIcon: ChatPersonaIcon.values.firstWhere(
        (e) => e.name == json['chatPersonaIcon'],
        orElse: () => ChatPersonaIcon.robot,
      ),
    );
  }
}
