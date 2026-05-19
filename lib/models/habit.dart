//blueprint of habits in app
//handels hive local storage and firestore for habits
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

//tell dart file generated from
part 'habit.g.dart';

//typeId : unique: each model : different typeId
@HiveType(typeId: 0)
class Habit extends HiveObject {
  Habit();

  //store the habit property wise
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String emoji;

  @HiveField(3)
  late String userId;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late List<DateTime> checkIns; //completion of task

  //create factory of habits
  factory Habit.create({
    required String title,
    required String emoji,
    required String userId,
  }) {
    return Habit()
      ..id = const Uuid().v4()
      ..title = title
      ..emoji = emoji
      ..userId = userId
      ..createdAt = DateTime.now()
      ..checkIns = [];
  }

  //check task completed on time
  bool isCompletedOn(DateTime date) {
    return checkIns.any(
      (checkIns) =>
          checkIns.year == date.year &&
          checkIns.month == date.month &&
          checkIns.day == date.day,
    );
  }

  //current streak
  int get currentStreak {
    if (checkIns.isEmpty) return 0;

    //sort checkIn from new to old
    final sorted = [...checkIns]..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    int streak = 0;

    //check for streak using date
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (final checkIns in sorted) {
      //take only date
      final checkInDay = DateTime(checkIns.year, checkIns.month, checkIns.day);

      //count streak
      if (checkInDay == checkDate) {
        streak++;

        //for other itteration check for previous day if habit exist
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (checkInDay.isBefore(checkDate)) {
        break; //break streak if gap
      }
    }
    return streak;

    //checkInDay : actual date user check in habit
    //checkDate: used to check if the particular date exist
  }

  //convert Habit to map to store in firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'checkIns': checkIns.map((d) => d.toIso8601String()).toList(),
    };
  }

  //create obj of habit (further to load from db)
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit()
      ..id = map['id']
      ..title = map['title']
      ..emoji = map['emoji']
      ..userId = map['userId']
      ..createdAt = (map['createdAt'] as Timestamp).toDate() //convert back to dateTime
      ..checkIns = (map['checkIns'] as List)
          .map((d) => DateTime.parse(d as String))
          .toList();
  }
}
