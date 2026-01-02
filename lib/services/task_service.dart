import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'auth_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get tasks stream for current user
  Stream<List<TaskModel>> getTasksStream() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // Get tasks by status
  Stream<List<TaskModel>> getTasksByStatus(TaskStatus status) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // Get tasks by priority
  Stream<List<TaskModel>> getTasksByPriority(TaskPriority priority) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('priority', isEqualTo: priority.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // Get tasks due today
  Stream<List<TaskModel>> getTasksDueToday() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // Create task
  Future<String> createTask(TaskModel task) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final taskWithUser = task.copyWith(userId: userId);
    final docRef = await _firestore
        .collection('tasks')
        .add(taskWithUser.toFirestore());
    
    return docRef.id;
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id)
        .update(task.toFirestore());
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Mark task as completed
  Future<void> markTaskCompleted(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': TaskStatus.completed.name,
    });
  }

  // Mark task as in progress
  Future<void> markTaskInProgress(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': TaskStatus.inProgress.name,
    });
  }

  // Search tasks
  Future<List<TaskModel>> searchTasks(String query) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get overdue tasks
  Stream<List<TaskModel>> getOverdueTasks() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    final now = DateTime.now();

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [TaskStatus.pending.name, TaskStatus.inProgress.name])
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }
}
