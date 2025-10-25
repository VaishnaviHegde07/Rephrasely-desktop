import '../providers/hotkey_provider.dart';
import '../providers/history_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/hotkey_service.dart';
import '../services/text_processing_service.dart';
import '../services/notification_service.dart';

/// Coordinates the complete hotkey flow: capture → process → paste
class HotkeyCoordinatorService {
  final HotkeyService hotkeyService;
  final TextProcessingService textProcessingService;
  final HotkeyProvider hotkeyProvider;
  final HistoryProvider historyProvider;
  final DashboardProvider dashboardProvider;

  bool _isProcessing = false;

  HotkeyCoordinatorService({
    required this.hotkeyService,
    required this.textProcessingService,
    required this.hotkeyProvider,
    required this.historyProvider,
    required this.dashboardProvider,
  }) {
    _setupHotkeyListeners();
  }

  /// Setup listeners for hotkey events from native layer
  void _setupHotkeyListeners() {
    // Listen for text capture events
    hotkeyService.onTextCaptured = (hotkeyId, text) async {
      if (_isProcessing) {
        print('⚠️ HotkeyCoordinator: Already processing, ignoring');
        return;
      }
      _isProcessing = true;
      NotificationService.showCapturing();
      await _handleTextCaptured(hotkeyId, text);
    };

    // Listen for text capture errors
    hotkeyService.onTextCaptureError = (error) {
      print('❌ HotkeyCoordinator: Text capture error - $error');
      NotificationService.showError('Failed to capture text: $error');
      _isProcessing = false;
    };

    print('👂 HotkeyCoordinator: Listening for text capture events.');
  }

  /// Handle captured text from native layer
  Future<void> _handleTextCaptured(String hotkeyId, String text) async {
    print(
      '🎯 HotkeyCoordinator: Processing hotkey $hotkeyId with ${text.length} chars',
    );

    try {
      // Find the hotkey configuration
      final hotkey = hotkeyProvider.getHotkeyById(hotkeyId);
      if (hotkey == null) {
        print('❌ HotkeyCoordinator: Hotkey $hotkeyId not found');
        NotificationService.showError('Hotkey not found');
        _isProcessing = false;
        return;
      }

      // Validate text
      if (!textProcessingService.validateText(text)) {
        print('❌ HotkeyCoordinator: Invalid text');
        NotificationService.showError('No text selected');
        _isProcessing = false;
        return;
      }

      // Show processing notification if enabled
      if (hotkey.showNotification) {
        NotificationService.showProcessing(text.length);
      }

      // Process text with AI
      print('🤖 HotkeyCoordinator: Sending to AI...');
      final transformedText = await textProcessingService.processText(
        text: text,
        hotkey: hotkey,
      );

      print(
        '✅ HotkeyCoordinator: Received transformed text (${transformedText.length} chars)',
      );

      // Update token usage stats in dashboard
      await dashboardProvider.updateStatsForHotkeyUsage(
        originalText: text,
        transformedText: transformedText,
      );

      // Save to history if enabled
      if (hotkey.saveToHistory) {
        await hotkeyService.saveToHistory(
          hotkeyId: hotkey.id,
          hotkeyName: hotkey.name,
          originalText: text,
          transformedText: transformedText,
          modelName: hotkey.modelName,
          actionType: hotkey.actionType.displayName,
        );

        // Reload history to show new entry
        await historyProvider.reloadHistory();
      }

      // Always paste the result back (auto-replace)
      await _pasteResult(transformedText);

      // Show success notification if enabled
      if (hotkey.showNotification) {
        NotificationService.showSuccess('Text replaced');
      }

      print('✅ HotkeyCoordinator: Flow completed successfully');
    } catch (e) {
      print('❌ HotkeyCoordinator: Error processing text - $e');
      NotificationService.showError('Processing failed: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// Paste the result back to the application
  Future<void> _pasteResult(String text) async {
    // Always restore clipboard after pasting
    await hotkeyService.pasteResult(text, restoreClipboard: true);

    print('✅ HotkeyCoordinator: Pasted result');
  }

  /// Check if currently processing
  bool get isProcessing => _isProcessing;
}
