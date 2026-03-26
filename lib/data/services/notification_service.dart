import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/constants/app_colors.dart';
import 'app_preferences.dart';

/// Notification Service
/// Handles permission requests and FCM setup
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? get _firebaseMessaging {
    try {
      return FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('Firebase Messaging unavailable: $e');
      return null;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  Future<bool> requestPermission(BuildContext context) async {
    // Check current status
    var status = await Permission.notification.status;

    if (!context.mounted) return false;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Show explanation dialog first
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izinkan Notifikasi'),
          content: const Text(
            'LokerKu membutuhkan izin untuk mengirim notifikasi pengingat lamaran Anda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nanti'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Izinkan'),
            ),
          ],
        ),
      );

      if (shouldRequest != true) {
        return false;
      }

      // Request permission
      status = await Permission.notification.request();
      if (!context.mounted) return false;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      // Open app settings
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin Diblokir'),
          content: const Text(
            'Izin notifikasi diblokir. Buka pengaturan untuk mengaktifkannya.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    // Update preferences
    await AppPreferences.setNotificationsEnabled(status.isGranted);
    return status.isGranted;
  }

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    final messaging = _firebaseMessaging;
    if (messaging == null) return;

    // Request FCM permission (for iOS)
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Get FCM token
      final token = await messaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message notification: ${message.notification}');
          _showLocalNotification(message);
        }
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.data}');
        // Navigate based on message data if needed
      });
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    // For now, just print the notification
    // In production, use flutter_local_notifications package
    debugPrint('Notification: ${message.notification?.title}');
  }

  /// Placeholder for scheduling a reminder (logs for now)
  Future<void> scheduleJobReminder(
    int jobId,
    String title,
    DateTime scheduledAt,
  ) async {
    debugPrint(
      'Reminder scheduled for job $jobId ("$title") at ${scheduledAt.toIso8601String()}',
    );
  }

  /// Show notification permission result snackbar
  static void showPermissionResult(BuildContext context, bool granted) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted ? 'Izin notifikasi diberikan' : 'Izin notifikasi ditolak',
        ),
        backgroundColor: granted ? AppColors.success : AppColors.error,
      ),
    );
  }
}
