/// Abstraction over local notification display.
///
/// This service provides a platform-agnostic interface for showing local
/// notifications. Concrete implementations can delegate to packages such as
/// `flutter_local_notifications` when added to the project.
class NotificationService {
  /// Initialises the notification service.
  ///
  /// Call this once during app startup (e.g. inside
  /// [DependencyInjection.init]) before displaying any notifications.
  Future<void> init() async {
    // Scaffold: initialise flutter_local_notifications here when the package
    // is added to pubspec.yaml.
    //
    // Example:
    //   final plugin = FlutterLocalNotificationsPlugin();
    //   const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    //   const iosSettings = DarwinInitializationSettings();
    //   const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    //   await plugin.initialize(settings);
  }

  /// Displays a simple local notification with the given [title] and [body].
  ///
  /// [id] uniquely identifies the notification so it can be updated or
  /// cancelled later. Defaults to `0`.
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Scaffold: replace with real flutter_local_notifications call when the
    // package is added to pubspec.yaml.
    //
    // Example:
    //   const androidDetails = AndroidNotificationDetails(
    //     'default_channel',
    //     'Default',
    //     importance: Importance.high,
    //     priority: Priority.high,
    //   );
    //   const details = NotificationDetails(android: androidDetails);
    //   await plugin.show(id, title, body, details, payload: payload);
  }

  /// Cancels the notification with the given [id].
  Future<void> cancelNotification(int id) async {
    // Scaffold: await plugin.cancel(id);
  }

  /// Cancels all pending and displayed notifications.
  Future<void> cancelAllNotifications() async {
    // Scaffold: await plugin.cancelAll();
  }
}
