import 'package:intl/intl.dart';

/// Represents a single text transformation in history
class TransformationHistory {
  final String id;
  final String hotkeyId;
  final String hotkeyName;
  final String originalText;
  final String transformedText;
  final String modelName;
  final String actionType;
  final DateTime timestamp;

  TransformationHistory({
    required this.id,
    required this.hotkeyId,
    required this.hotkeyName,
    required this.originalText,
    required this.transformedText,
    required this.modelName,
    required this.actionType,
    required this.timestamp,
  });

  /// Create from JSON (from native layer)
  factory TransformationHistory.fromJson(Map<String, dynamic> json) {
    return TransformationHistory(
      id: json['id'] as String,
      hotkeyId: json['hotkeyId'] as String,
      hotkeyName: json['hotkeyName'] as String,
      originalText: json['originalText'] as String,
      transformedText: json['transformedText'] as String,
      modelName: json['modelName'] as String,
      actionType: json['actionType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotkeyId': hotkeyId,
      'hotkeyName': hotkeyName,
      'originalText': originalText,
      'transformedText': transformedText,
      'modelName': modelName,
      'actionType': actionType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get formatted timestamp (e.g., "2:30 PM")
  String get formattedTime {
    return DateFormat.jm().format(timestamp.toLocal());
  }

  /// Get time only (e.g., "2:30 PM")
  String get timeOnly {
    return DateFormat.jm().format(timestamp.toLocal());
  }

  /// Get formatted date (e.g., "Jan 15, 2024")
  String get formattedDate {
    return DateFormat('MMM d, y').format(timestamp.toLocal());
  }

  /// Get relative time (e.g., "5 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return formattedDate;
    }
  }

  /// Get date key for grouping (e.g., "Today", "Yesterday", "Jan 15, 2024")
  String get dateGroupKey {
    final now = DateTime.now();
    final itemLocal = timestamp.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(itemLocal.year, itemLocal.month, itemLocal.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return formattedDate;
    }
  }

  /// Create a copy with updated fields
  TransformationHistory copyWith({
    String? id,
    String? hotkeyId,
    String? hotkeyName,
    String? originalText,
    String? transformedText,
    String? modelName,
    String? actionType,
    DateTime? timestamp,
  }) {
    return TransformationHistory(
      id: id ?? this.id,
      hotkeyId: hotkeyId ?? this.hotkeyId,
      hotkeyName: hotkeyName ?? this.hotkeyName,
      originalText: originalText ?? this.originalText,
      transformedText: transformedText ?? this.transformedText,
      modelName: modelName ?? this.modelName,
      actionType: actionType ?? this.actionType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
