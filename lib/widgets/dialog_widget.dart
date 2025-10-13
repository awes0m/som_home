import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            style: isDangerous
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class InfoDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

class InputDialog {
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hint,
    String? label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
          ),
          keyboardType: keyboardType,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog {
  static bool _isShowing = false;

  static Future<void> show(BuildContext context, {String? message}) async {
    if (_isShowing) return;
    _isShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(message ?? 'Loading...')),
            ],
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}