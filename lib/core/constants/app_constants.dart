class AppConstants {
  // App Info
  static const String appName = 'Listo';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Personal Online Assistant';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String eventsCollection = 'events';

  // Shared Preferences Keys
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyVoiceEnabled = 'voice_enabled';

  // Notification Channels
  static const String notificationChannelId = 'listo_notifications';
  static const String notificationChannelName = 'Listo Notifications';
  static const String notificationChannelDescription = 'Notifications for tasks and reminders';

  // Voice Commands
  static const List<String> voiceCommandKeywords = [
    'remind',
    'task',
    'add',
    'create',
    'schedule',
    'event',
    'meeting',
    'appointment',
  ];

  // Date & Time Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Demo Credentials
  static const String demoEmail = 'demo@listo.app';
  static const String demoPassword = 'Demo123!';

  // Limits
  static const int maxTasksPerUser = 1000;
  static const int maxEventsPerUser = 500;
  static const int voiceCommandTimeoutSeconds = 5;
  static const double voiceRecognitionAccuracyThreshold = 0.9;

  // Error Messages
  static const String errorNoInternet = 'No internet connection. Please check your network.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorFirestore = 'Failed to sync data. Please check your connection.';
  static const String errorVoicePermission = 'Microphone permission required for voice commands.';
  static const String errorNotificationPermission = 'Notification permission required for reminders.';
}
