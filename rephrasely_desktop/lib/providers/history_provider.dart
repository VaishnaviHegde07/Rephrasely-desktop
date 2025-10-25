import 'package:flutter/material.dart';
import '../models/transformation_history.dart';
import '../services/hotkey_service.dart';

/// Manages transformation history state
class HistoryProvider extends ChangeNotifier {
  final HotkeyService _hotkeyService;

  List<TransformationHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  HistoryProvider(this._hotkeyService) {
    _loadHistory();
  }

  // Getters
  List<TransformationHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _history.isEmpty;

  /// Get history grouped by date
  Map<String, List<TransformationHistory>> get historyGroupedByDate {
    final grouped = <String, List<TransformationHistory>>{};

    for (final entry in _history) {
      final dateKey = entry.dateGroupKey;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }

    return grouped;
  }

  /// Get sorted date keys (most recent first)
  List<String> get dateKeys {
    final keys = historyGroupedByDate.keys.toList();

    // Custom sort to put "Today" and "Yesterday" first
    keys.sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;

      // Parse dates and sort descending
      try {
        final dateA = DateTime.parse(a);
        final dateB = DateTime.parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return keys;
  }

  /// Load history from native storage
  Future<void> _loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final historyData = await _hotkeyService.getHistory();
      _history =
          historyData
              .map((json) => TransformationHistory.fromJson(json))
              .toList();

      print('📚 HistoryProvider: Loaded ${_history.length} entries');
    } catch (e) {
      _error = 'Failed to load history: $e';
      print('❌ HistoryProvider: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload history (e.g., after adding/deleting)
  Future<void> reloadHistory() async {
    await _loadHistory();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _hotkeyService.clearHistory();
      _history = [];
      print('🗑️ HistoryProvider: Cleared all history');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear history: $e';
      print('❌ HistoryProvider: $_error');
      notifyListeners();
    }
  }

  /// Delete a specific history entry
  Future<void> deleteEntry(String id) async {
    try {
      await _hotkeyService.deleteHistoryEntry(id);
      _history.removeWhere((entry) => entry.id == id);
      print('🗑️ HistoryProvider: Deleted entry $id');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete entry: $e';
      print('❌ HistoryProvider: $_error');
      notifyListeners();
    }
  }

  /// Search history
  List<TransformationHistory> searchHistory(String query) {
    if (query.isEmpty) return _history;

    final lowerQuery = query.toLowerCase();
    return _history.where((entry) {
      return entry.hotkeyName.toLowerCase().contains(lowerQuery) ||
          entry.originalText.toLowerCase().contains(lowerQuery) ||
          entry.transformedText.toLowerCase().contains(lowerQuery) ||
          entry.actionType.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get history for a specific hotkey
  List<TransformationHistory> getHistoryForHotkey(String hotkeyId) {
    return _history.where((entry) => entry.hotkeyId == hotkeyId).toList();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    if (_history.isEmpty) {
      return {'total': 0, 'today': 0, 'thisWeek': 0, 'mostUsedAction': 'None'};
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayCount = _history.where((e) => e.timestamp.isAfter(today)).length;
    final weekCount =
        _history.where((e) => e.timestamp.isAfter(weekAgo)).length;

    // Find most used action type
    final actionCounts = <String, int>{};
    for (final entry in _history) {
      actionCounts[entry.actionType] =
          (actionCounts[entry.actionType] ?? 0) + 1;
    }
    final mostUsedAction =
        actionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'total': _history.length,
      'today': todayCount,
      'thisWeek': weekCount,
      'mostUsedAction': mostUsedAction,
    };
  }
}
