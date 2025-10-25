import 'package:flutter/services.dart';
import 'dart:async';

/// Service for communicating with native hotkey system
class HotkeyService {
  static const platform = MethodChannel('com.rephrasely/hotkeys');

  // Callbacks
  Function(String hotkeyId)? onHotkeyPressed;
  Function(String hotkeyId, String text)? onTextCaptured;
  Function(String error)? onTextCaptureError;

  HotkeyService() {
    _setupListeners();
  }

  /// Setup listeners for native callbacks
  void _setupListeners() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onHotkeyPressed':
          final hotkeyId = call.arguments as String;
          print('🔥 HotkeyService: Hotkey pressed - $hotkeyId');
          onHotkeyPressed?.call(hotkeyId);
          break;

        case 'onTextCaptured':
          final args = call.arguments as Map;
          final hotkeyId = args['hotkeyId'] as String;
          final text = args['text'] as String;
          print('📥 HotkeyService: Text captured - ${text.length} chars');
          onTextCaptured?.call(hotkeyId, text);
          break;

        case 'onTextCaptureError':
          final error = call.arguments as String;
          print('❌ HotkeyService: Text capture error - $error');
          onTextCaptureError?.call(error);
          break;
      }
    });
  }

  /// Register a hotkey with the native system
  Future<bool> registerHotkey(String id, String keyCombo) async {
    try {
      final result = await platform.invokeMethod('registerHotkey', {
        'id': id,
        'keyCombo': keyCombo,
      });
      print('✅ HotkeyService: Registered hotkey $id -> $keyCombo');
      return result as bool;
    } catch (e) {
      print('❌ HotkeyService: Failed to register hotkey - $e');
      return false;
    }
  }

  /// Unregister a hotkey
  Future<void> unregisterHotkey(String id) async {
    try {
      await platform.invokeMethod('unregisterHotkey', {'id': id});
      print('🗑️ HotkeyService: Unregistered hotkey $id');
    } catch (e) {
      print('❌ HotkeyService: Failed to unregister hotkey - $e');
    }
  }

  /// Unregister all hotkeys
  Future<void> unregisterAllHotkeys() async {
    try {
      await platform.invokeMethod('unregisterAllHotkeys');
      print('🗑️ HotkeyService: Unregistered all hotkeys');
    } catch (e) {
      print('❌ HotkeyService: Failed to unregister all hotkeys - $e');
    }
  }

  /// Paste transformed text back to the application
  Future<void> pasteResult(String text, {bool restoreClipboard = true}) async {
    try {
      await platform.invokeMethod('pasteResult', {
        'text': text,
        'restoreClipboard': restoreClipboard,
      });
      print('✅ HotkeyService: Pasted result');
    } catch (e) {
      print('❌ HotkeyService: Failed to paste result - $e');
    }
  }

  /// Save transformation to history
  Future<void> saveToHistory({
    required String hotkeyId,
    required String hotkeyName,
    required String originalText,
    required String transformedText,
    required String modelName,
    required String actionType,
  }) async {
    try {
      await platform.invokeMethod('saveToHistory', {
        'hotkeyId': hotkeyId,
        'hotkeyName': hotkeyName,
        'originalText': originalText,
        'transformedText': transformedText,
        'modelName': modelName,
        'actionType': actionType,
      });
      print('💾 HotkeyService: Saved to history');
    } catch (e) {
      print('❌ HotkeyService: Failed to save to history - $e');
    }
  }

  /// Get all history entries
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final result = await platform.invokeMethod('getHistory');
      if (result == null) return [];

      final list = result as List;
      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      print('❌ HotkeyService: Failed to get history - $e');
      return [];
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await platform.invokeMethod('clearHistory');
      print('🗑️ HotkeyService: Cleared history');
    } catch (e) {
      print('❌ HotkeyService: Failed to clear history - $e');
    }
  }

  /// Delete a specific history entry
  Future<void> deleteHistoryEntry(String id) async {
    try {
      await platform.invokeMethod('deleteHistoryEntry', {'id': id});
      print('🗑️ HotkeyService: Deleted history entry $id');
    } catch (e) {
      print('❌ HotkeyService: Failed to delete history entry - $e');
    }
  }
}
