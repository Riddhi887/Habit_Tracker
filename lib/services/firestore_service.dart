//handel and bridge communicaton between firestore db and app
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/models/habit.dart';

class FirestoreService {
  //create instance to get access to db
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //create collection for user to see their own habit
  CollectionReference<Map<String, dynamic>> _habitRef(String userId) {
    return _db.collection('users').doc(userId).collection('habits');
  }

  //saving a habit
  Future<void> saveHabit(Habit habit) async {
    await _habitRef(
      habit.userId,
    ).doc(habit.id).set(habit.toMap(), SetOptions(merge: true));
  }

  //delete a habit
  Future<void> deleteHabit(String userId, String habitId) async {
    await _habitRef(userId).doc(habitId).delete();
  }

  //get habit stream: automatic updates on app : when change in db
  Stream<List<Habit>> getHabitStream(String userId) {
    return _habitRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
    });
  }
}
