import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:get/get.dart';

class AppMinimizeService extends GetxService {
  static AppMinimizeService get to => Get.find();
  
  /// Minimize the app with platform-specific handling
  Future<void> minimizeApp() async {
    try {
      if (Platform.isAndroid) {
        // Android: Use the minimize plugin
        await FlutterAppMinimizerPlus.minimizeApp();
      } else if (Platform.isIOS) {
        // iOS: Since programmatic minimization is not allowed by Apple,
        // we'll show a dialog explaining the limitation and provide alternatives
        await _showIOSMinimizeDialog();
      }
    } catch (e) {
      print('Error minimizing app: $e');
      // Fallback: Show a message to the user
      Get.snackbar(
        'Minimize App',
        'Unable to minimize app. Please use the home button or swipe up gesture.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Show iOS-specific dialog explaining minimize limitations
  Future<void> _showIOSMinimizeDialog() async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Minimize App'),
          content: const Text(
            'iOS doesn\'t allow apps to minimize themselves programmatically. '
            'To minimize this app, please:\n\n'
            '• Swipe up from the bottom edge of the screen\n'
            '• Or press the home button\n\n'
            'The app will continue running in the background and can process transactions automatically.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Go to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to home screen as an alternative
                Get.offAllNamed('/home');
              },
            ),
          ],
        );
      },
    );
  }
  
  /// Check if the current platform supports programmatic minimization
  bool get supportsMinimize {
    return Platform.isAndroid;
  }
  
  /// Get platform-specific minimize button text
  String get minimizeButtonText {
    if (Platform.isAndroid) {
      return 'Minimize application';
    } else if (Platform.isIOS) {
      return 'Background info';
    }
    return 'Minimize application';
  }
  
  /// Get platform-specific minimize button icon
  IconData get minimizeButtonIcon {
    if (Platform.isAndroid) {
      return Icons.flip_to_back_outlined;
    } else if (Platform.isIOS) {
      return Icons.info_outline;
    }
    return Icons.flip_to_back_outlined;
  }
}





