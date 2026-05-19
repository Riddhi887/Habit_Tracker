//manages the state of habits in app

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/firestore_service.dart';

//give widget access to Firestore so other provide can use it
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

//create stream provider : created stream of habits in firestoreService
final habitProvider = StreamProvider<List<Habit>>((ref) {
  //get firestoreService
  final firestoreService = ref.read(firestoreServiceProvider);

  //get currently loggedin user
  final userId = FirebaseAuth.instance.currentUser?.uid;

  //if no user logged in return empty list of stream
  if (userId == null) return Stream.value([]);

  //if user logged in display its habit stream
  return firestoreService.getHabitStream(userId);
});

//StateNotifer class : to controll habits
class HabitNotifier extends StateNotifier<List<Habit>> {
  final FirestoreService _firestoreService;

  //set inital state to empty list
  HabitNotifier(this._firestoreService) : super([]);

  //add habit : save to firestore
  Future<void> addHabit({
    required String title,
    required String emoji,
    required String userId,
  }) async {
    final habit = Habit.create(title: title, emoji: emoji, userId: userId);

    //save to firestore
    await _firestoreService.saveHabit(habit);
  }

  //mark habit done or undone (checkins)
  Future<void> toggleCheckIn(Habit habit) async {
    final today = DateTime.now();

    if (habit.isCompletedOn(today)) {
      //mark it as done
      habit.checkIns.removeWhere(
        (d) =>
            d.year == today.year &&
            d.month == today.month &&
            d.day == today.day,
      );
    } else {
      habit.checkIns.add(today); //not done show to checkin today
    }

    //save updated habit to firestore
    await _firestoreService.saveHabit(habit);
  }

  //delete habit
  Future<void> deleteHabit(String userId, String habitId) async {
    await _firestoreService.deleteHabit(userId, habitId);
  }
}

// StateNotifierProvider exposes the HabitNotifier to the rest of the app
// Screens use this to call addHabit(), toggleCheckIn(), deleteHabit()
final habitNotifierProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) {
    return HabitNotifier(ref.read(firestoreServiceProvider));
  },
);
