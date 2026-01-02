import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/speech_to_text_service.dart';
import '../../services/text_to_speech_service.dart';
import '../../services/task_service.dart';
import '../../services/event_service.dart';
import '../../models/task_model.dart';
import '../../models/event_model.dart';
import '../tasks/tasks_tab.dart';
import '../calendar/calendar_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _speechService = SpeechToTextService();
  final _ttsService = TextToSpeechService();
  final _taskService = TaskService();
  final _eventService = EventService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _startVoiceCommand() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    final hasPermission = await _speechService.hasPermission();
    if (!hasPermission) {
      final granted = await _speechService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required for voice commands'),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isListening = true);

    await _speechService.startListening(
      onResult: (text) async {
        setState(() => _isListening = false);
        await _processVoiceCommand(text);
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice error: $error')),
        );
      },
    );
  }

  Future<void> _processVoiceCommand(String command) async {
    final parsed = _speechService.parseVoiceCommand(command);
    
    if (parsed == null) {
      await _ttsService.speak('Sorry, I didn\'t understand that command');
      return;
    }

    try {
      if (parsed['type'] == 'task') {
        // Create task
        final task = TaskModel(
          id: '',
          title: parsed['title'] ?? 'New Task',
          description: '',
          createdAt: DateTime.now(),
          dueDate: parsed['dueDate'],
          reminderTime: parsed['reminderTime'],
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          userId: '',
          hasReminder: parsed['reminderTime'] != null,
        );
        
        await _taskService.createTask(task);
        await _ttsService.speakTaskConfirmation(task.title);
      } else if (parsed['type'] == 'event') {
        // Create event
        final event = EventModel(
          id: '',
          title: parsed['title'] ?? 'New Event',
          description: '',
          startTime: parsed['startTime'] ?? DateTime.now(),
          endTime: parsed['endTime'] ?? DateTime.now().add(const Duration(hours: 1)),
          location: parsed['location'] ?? '',
          type: EventType.personal,
          userId: '',
          timezone: DateTime.now().timeZoneName,
        );
        
        await _eventService.createEvent(event);
        await _ttsService.speakEventConfirmation(event.title);
      }
    } catch (e) {
      await _ttsService.speak('Sorry, failed to create the item');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TasksTab(),
      const CalendarTab(),
      const Center(child: Text('Settings (Coming Soon)')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startVoiceCommand,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
        label: Text(_isListening ? 'Listening...' : 'Voice Command'),
        backgroundColor: _isListening ? Colors.red : null,
      ),
    );
  }
}
