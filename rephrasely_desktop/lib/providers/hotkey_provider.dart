import 'package:flutter/material.dart';
import '../models/hotkey.dart';
import '../services/storage_service.dart';
import '../services/hotkey_service.dart';

class HotkeyProvider extends ChangeNotifier {
  final StorageService _storageService;
  final HotkeyService _hotkeyService;

  List<Hotkey> _hotkeys = [];
  Hotkey? _selectedHotkey;
  bool _isLoading = false;
  String? _error;

  // Callback to update dashboard stats
  Function(int count)? onHotkeyCountChanged;

  HotkeyProvider(this._storageService, this._hotkeyService) {
    _loadHotkeys();
  }

  // Getters
  List<Hotkey> get hotkeys => _hotkeys;
  List<Hotkey> get activeHotkeys => _hotkeys.where((h) => h.isActive).toList();
  Hotkey? get selectedHotkey => _selectedHotkey;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load hotkeys from storage
  Future<void> _loadHotkeys() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _storageService.getData('hotkeys');
      if (data != null && data is List) {
        _hotkeys =
            data
                .map((json) => Hotkey.fromJson(json as Map<String, dynamic>))
                .toList();
      } else {
        // Initialize with some default hotkeys
        _hotkeys = _getDefaultHotkeys();
        await _saveHotkeys();
      }

      // Sync active hotkeys with native system
      await _syncHotkeysWithNative();
    } catch (e) {
      _error = 'Failed to load hotkeys: $e';
      _hotkeys = _getDefaultHotkeys();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save hotkeys to storage
  Future<void> _saveHotkeys() async {
    try {
      final data = _hotkeys.map((h) => h.toJson()).toList();
      await _storageService.saveData('hotkeys', data);
    } catch (e) {
      _error = 'Failed to save hotkeys: $e';
      notifyListeners();
    }
  }

  // Add a new hotkey
  Future<void> addHotkey(Hotkey hotkey) async {
    _hotkeys.add(hotkey);
    await _saveHotkeys();

    // Register with native system if active
    if (hotkey.isActive) {
      await _hotkeyService.registerHotkey(hotkey.id, hotkey.keyCombo);
    }

    // Update dashboard stats
    onHotkeyCountChanged?.call(_hotkeys.length);

    notifyListeners();
  }

  // Update an existing hotkey
  Future<void> updateHotkey(Hotkey hotkey) async {
    final index = _hotkeys.indexWhere((h) => h.id == hotkey.id);
    if (index != -1) {
      final oldHotkey = _hotkeys[index];
      _hotkeys[index] = hotkey;
      if (_selectedHotkey?.id == hotkey.id) {
        _selectedHotkey = hotkey;
      }
      await _saveHotkeys();

      // Update native registration
      await _hotkeyService.unregisterHotkey(oldHotkey.id);
      if (hotkey.isActive) {
        await _hotkeyService.registerHotkey(hotkey.id, hotkey.keyCombo);
      }

      notifyListeners();
    }
  }

  // Delete a hotkey
  Future<void> deleteHotkey(String id) async {
    // Unregister from native system first
    await _hotkeyService.unregisterHotkey(id);

    _hotkeys.removeWhere((h) => h.id == id);
    if (_selectedHotkey?.id == id) {
      _selectedHotkey = null;
    }
    await _saveHotkeys();

    // Update dashboard stats
    onHotkeyCountChanged?.call(_hotkeys.length);

    notifyListeners();
  }

  // Toggle hotkey active state
  Future<void> toggleHotkey(String id) async {
    final index = _hotkeys.indexWhere((h) => h.id == id);
    if (index != -1) {
      final wasActive = _hotkeys[index].isActive;
      _hotkeys[index] = _hotkeys[index].copyWith(isActive: !wasActive);

      // Update native registration
      if (_hotkeys[index].isActive) {
        await _hotkeyService.registerHotkey(
          _hotkeys[index].id,
          _hotkeys[index].keyCombo,
        );
      } else {
        await _hotkeyService.unregisterHotkey(id);
      }

      await _saveHotkeys();
      notifyListeners();
    }
  }

  /// Sync all active hotkeys with native system
  Future<void> _syncHotkeysWithNative() async {
    // Unregister all first
    await _hotkeyService.unregisterAllHotkeys();

    // Register all active hotkeys
    for (final hotkey in _hotkeys.where((h) => h.isActive)) {
      await _hotkeyService.registerHotkey(hotkey.id, hotkey.keyCombo);
    }

    print(
      '🔄 HotkeyProvider: Synced ${activeHotkeys.length} active hotkeys with native system',
    );
  }

  /// Get hotkey by ID
  Hotkey? getHotkeyById(String id) {
    try {
      return _hotkeys.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  // Select a hotkey for editing
  void selectHotkey(Hotkey? hotkey) {
    _selectedHotkey = hotkey;
    notifyListeners();
  }

  // Update last used time
  Future<void> updateLastUsed(String id) async {
    final index = _hotkeys.indexWhere((h) => h.id == id);
    if (index != -1) {
      _hotkeys[index] = _hotkeys[index].copyWith(lastUsed: DateTime.now());
      await _saveHotkeys();
      notifyListeners();
    }
  }

  // Get default hotkeys for first-time users
  List<Hotkey> _getDefaultHotkeys() {
    return [
      Hotkey(
        id: '1',
        name: 'Rephrase Professionally',
        keyCombo: 'cmd+shift+R',
        modelId: 'openai/gpt-4-turbo',
        modelName: 'OpenAI: GPT-4 Turbo',
        actionType: HotkeyActionType.rephrase,
        style: HotkeyStyle.professional,
        isActive: true,
        showNotification: true,
        saveToHistory: true,
      ),
      Hotkey(
        id: '2',
        name: 'Fix Grammar',
        keyCombo: 'cmd+shift+G',
        modelId: 'openai/gpt-4-turbo',
        modelName: 'OpenAI: GPT-4 Turbo',
        actionType: HotkeyActionType.fixGrammar,
        isActive: true,
        showNotification: true,
        saveToHistory: true,
      ),
      Hotkey(
        id: '3',
        name: 'Summarize',
        keyCombo: 'cmd+shift+S',
        modelId: 'openai/gpt-4-turbo',
        modelName: 'OpenAI: GPT-4 Turbo',
        actionType: HotkeyActionType.summarize,
        style: HotkeyStyle.concise,
        isActive: true,
        showNotification: true,
        saveToHistory: true,
      ),
    ];
  }

  // Reload hotkeys
  Future<void> reload() async {
    await _loadHotkeys();
  }
}
