import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/firestore_service.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Auth state provider: listens to login/logout changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Habit stream provider: reacts to auth state changes
final habitProvider = StreamProvider<List<Habit>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getHabitStream(user.uid);
});

// StateNotifier for habit actions
class HabitNotifier extends StateNotifier<List<Habit>> {
  final FirestoreService _firestoreService;
  HabitNotifier(this._firestoreService) : super([]);

  Future<void> addHabit({
    required String title,
    required String emoji,
    required String userId,
  }) async {
    final habit = Habit.create(title: title, emoji: emoji, userId: userId);
    await _firestoreService.saveHabit(habit);
  }

  Future<void> toggleCheckIn(Habit habit) async {
    final today = DateTime.now();
    if (habit.isCompletedOn(today)) {
      habit.checkIns.removeWhere(
        (d) =>
            d.year == today.year &&
            d.month == today.month &&
            d.day == today.day,
      );
    } else {
      habit.checkIns.add(today);
    }
    await _firestoreService.saveHabit(habit);
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    await _firestoreService.deleteHabit(userId, habitId);
  }
}

final habitNotifierProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) => HabitNotifier(ref.read(firestoreServiceProvider)),
);
