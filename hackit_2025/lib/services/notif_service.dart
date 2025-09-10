import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  // Why have a underscore value and normal value?
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  //INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization
    //prepare Android init settings

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // To find icon of app I think

    const initSettings = InitializationSettings(android: initSettingsAndroid);

    // initialize plugin
    await notificationsPlugin.initialize(initSettings);
  }

  // NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: // Setup channel id and channel name
      AndroidNotificationDetails(
        "daily_channel_id",
        'Daily Notifications',
        channelDescription: 'Daily Notifications Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //METHOD TO SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }
}
