import 'package:intl/intl.dart';

class VoiceCommandParser {
  // Parse voice command and extract task/event information
  static Map<String, dynamic>? parseCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();

    // Check for reminder/task creation
    if (_isReminderCommand(lowerCommand)) {
      return _parseReminderCommand(lowerCommand);
    }

    // Check for event/meeting creation
    if (_isEventCommand(lowerCommand)) {
      return _parseEventCommand(lowerCommand);
    }

    return null;
  }

  static bool _isReminderCommand(String command) {
    return command.contains('remind') ||
        command.contains('task') ||
        command.contains('todo') ||
        command.contains('add task');
  }

  static bool _isEventCommand(String command) {
    return command.contains('schedule') ||
        command.contains('meeting') ||
        command.contains('appointment') ||
        command.contains('event');
  }

  static Map<String, dynamic> _parseReminderCommand(String command) {
    String? title;
    DateTime? dueDate;
    DateTime? reminderTime;

    // Extract title after "remind me to" or similar
    final titlePatterns = [
      RegExp(r'remind me to (.+?)(?:at|on|by|$)', caseSensitive: false),
      RegExp(r'add task (.+?)(?:at|on|by|$)', caseSensitive: false),
      RegExp(r'create task (.+?)(?:at|on|by|$)', caseSensitive: false),
      RegExp(r'task (.+?)(?:at|on|by|$)', caseSensitive: false),
    ];

    for (final pattern in titlePatterns) {
      final match = pattern.firstMatch(command);
      if (match != null) {
        title = match.group(1)?.trim();
        break;
      }
    }

    // Extract time
    reminderTime = _extractTime(command);

    // Extract date
    dueDate = _extractDate(command);

    return {
      'type': 'task',
      'title': title ?? command.replaceAll(RegExp(r'(remind me to|add task|create task|task)', caseSensitive: false), '').trim(),
      'dueDate': dueDate,
      'reminderTime': reminderTime ?? dueDate,
    };
  }

  static Map<String, dynamic> _parseEventCommand(String command) {
    String? title;
    DateTime? startTime;
    DateTime? endTime;
    String? location;

    // Extract title
    final titlePatterns = [
      RegExp(r'schedule (.+?)(?:at|on|for|$)', caseSensitive: false),
      RegExp(r'meeting with (.+?)(?:at|on|for|$)', caseSensitive: false),
      RegExp(r'appointment with (.+?)(?:at|on|for|$)', caseSensitive: false),
      RegExp(r'event (.+?)(?:at|on|for|$)', caseSensitive: false),
    ];

    for (final pattern in titlePatterns) {
      final match = pattern.firstMatch(command);
      if (match != null) {
        title = match.group(1)?.trim();
        break;
      }
    }

    // Extract time
    startTime = _extractTime(command);

    // If time extracted, set end time to 1 hour later
    if (startTime != null) {
      endTime = startTime.add(const Duration(hours: 1));
    }

    return {
      'type': 'event',
      'title': title ?? command.replaceAll(RegExp(r'(schedule|meeting|appointment|event)', caseSensitive: false), '').trim(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
    };
  }

  static DateTime? _extractTime(String command) {
    final now = DateTime.now();
    
    // Pattern for time with AM/PM (e.g., "3 pm", "3:30 pm")
    final timePattern = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)', caseSensitive: false);
    final match = timePattern.firstMatch(command);
    
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3)!.toLowerCase();
      
      if (period == 'pm' && hour != 12) {
        hour += 12;
      } else if (period == 'am' && hour == 12) {
        hour = 0;
      }
      
      DateTime time = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If time is in the past today, schedule for tomorrow
      if (time.isBefore(now)) {
        time = time.add(const Duration(days: 1));
      }
      
      return time;
    }

    // Pattern for 24-hour time (e.g., "15:30", "14:00")
    final time24Pattern = RegExp(r'(\d{1,2}):(\d{2})');
    final match24 = time24Pattern.firstMatch(command);
    
    if (match24 != null) {
      final hour = int.parse(match24.group(1)!);
      final minute = int.parse(match24.group(2)!);
      
      DateTime time = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (time.isBefore(now)) {
        time = time.add(const Duration(days: 1));
      }
      
      return time;
    }

    return null;
  }

  static DateTime? _extractDate(String command) {
    final now = DateTime.now();
    final lowerCommand = command.toLowerCase();

    // Check for relative dates
    if (lowerCommand.contains('today')) {
      return DateTime(now.year, now.month, now.day);
    }
    
    if (lowerCommand.contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    // Check for day of week
    final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (lowerCommand.contains(daysOfWeek[i])) {
        final targetDay = i + 1; // 1-7 for Monday-Sunday
        final currentDay = now.weekday;
        int daysToAdd = (targetDay - currentDay + 7) % 7;
        if (daysToAdd == 0) daysToAdd = 7; // Next week if same day
        final targetDate = now.add(Duration(days: daysToAdd));
        return DateTime(targetDate.year, targetDate.month, targetDate.day);
      }
    }

    // Try to parse specific date formats
    try {
      final dateFormats = [
        'MMMM d',
        'MMM d',
        'M/d',
        'MM/dd',
        'd MMMM',
        'd MMM',
      ];

      for (final format in dateFormats) {
        try {
          // Extract potential date string from command
          final words = command.split(' ');
          for (int i = 0; i < words.length - 1; i++) {
            final dateStr = '${words[i]} ${words[i + 1]}';
            try {
              final date = DateFormat(format).parse(dateStr);
              return DateTime(now.year, date.month, date.day);
            } catch (e) {
              continue;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return null;
  }

  // Generate confirmation message
  static String generateConfirmation(Map<String, dynamic> parsed) {
    if (parsed['type'] == 'task') {
      String message = 'Task created: ${parsed['title']}';
      if (parsed['reminderTime'] != null) {
        final time = DateFormat('MMM dd at hh:mm a').format(parsed['reminderTime']);
        message += ' reminder set for $time';
      }
      return message;
    } else if (parsed['type'] == 'event') {
      String message = 'Event scheduled: ${parsed['title']}';
      if (parsed['startTime'] != null) {
        final time = DateFormat('MMM dd at hh:mm a').format(parsed['startTime']);
        message += ' at $time';
      }
      return message;
    }
    return 'Command processed';
  }
}
