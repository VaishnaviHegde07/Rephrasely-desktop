import 'package:flutter/material.dart';

/// Service to show floating notifications for hotkey operations
class NotificationService {
  static OverlayEntry? _currentOverlay;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void show(
    String message, {
    IconData icon = Icons.info_outline,
    Color color = Colors.blue,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Remove existing overlay if any
    dismiss();

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ NotificationService: No context available');
      return;
    }

    // Find the overlay - need to get it from the Navigator state
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) {
      print('⚠️ NotificationService: No navigator state');
      return;
    }

    _currentOverlay = OverlayEntry(
      builder:
          (context) => _FloatingNotification(
            message: message,
            icon: icon,
            color: color,
            onDismiss: dismiss,
          ),
    );

    navigatorState.overlay?.insert(_currentOverlay!);

    // Auto dismiss after duration
    Future.delayed(duration, dismiss);
  }

  static void showCapturing() {
    show(
      'Capturing selected text...',
      icon: Icons.content_copy,
      color: Colors.orange,
      duration: const Duration(seconds: 1),
    );
  }

  static void showProcessing(int charCount) {
    show(
      'Processing $charCount characters...',
      icon: Icons.sync,
      color: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }

  static void showSuccess(String action) {
    show(
      '$action completed!',
      icon: Icons.check_circle,
      color: Colors.green,
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String error) {
    show(
      error,
      icon: Icons.error_outline,
      color: Colors.red,
      duration: const Duration(seconds: 3),
    );
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _FloatingNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;

  const _FloatingNotification({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<_FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
