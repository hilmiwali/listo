import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Get relative time (e.g., "2 hours ago", "Tomorrow")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past
      final absDifference = difference.abs();
      if (absDifference.inMinutes < 1) {
        return 'Just now';
      } else if (absDifference.inMinutes < 60) {
        return '${absDifference.inMinutes} min ago';
      } else if (absDifference.inHours < 24) {
        return '${absDifference.inHours} hour${absDifference.inHours > 1 ? 's' : ''} ago';
      } else if (absDifference.inDays < 7) {
        return '${absDifference.inDays} day${absDifference.inDays > 1 ? 's' : ''} ago';
      } else {
        return formatDate(dateTime);
      }
    } else {
      // Future
      if (difference.inMinutes < 60) {
        return 'In ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inDays == 0) {
        return 'Today at ${formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow at ${formatTime(dateTime)}';
      } else if (difference.inDays < 7) {
        return 'In ${difference.inDays} days';
      } else {
        return formatDate(dateTime);
      }
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Parse natural language time (e.g., "3 pm", "15:30")
  static DateTime? parseTime(String timeString, DateTime baseDate) {
    try {
      // Try various time formats
      final formats = [
        'h:mm a',
        'hh:mm a',
        'h a',
        'HH:mm',
        'H:mm',
      ];

      for (final format in formats) {
        try {
          final time = DateFormat(format).parse(timeString);
          return DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            time.hour,
            time.minute,
          );
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get timezone offset string (e.g., "UTC+5:30")
  static String getTimezoneOffset() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    return 'UTC${hours >= 0 ? '+' : ''}$hours${minutes > 0 ? ':${minutes.toString().padLeft(2, '0')}' : ''}';
  }
}
