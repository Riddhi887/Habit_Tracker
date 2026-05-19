import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/add_habit_screen.dart';
import 'package:habit_tracker/screens/login_screen.dart';
import 'package:habit_tracker/services/auth_service.dart';
import 'package:habit_tracker/screens/insights_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //auto update
    final habitAsync = ref.watch(habitProvider);

    //get current user logged in
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi ${user?.displayName ?? 'there!'}'),
        //?? if null then display there else of name
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              //go to login screen after logout
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),

      body: habitAsync.when(
        error: (err, _) => Center(child: Text('Something went wrong: $err')),

        loading: () => const Center(child: CircularProgressIndicator()),

        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No habits yet!', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first habit',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _HabitCard(habit: habit);
            },
          );
        },
      ),

      //insigths button
      floatingActionButton: habitAsync.when(
        data: (habits) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InsightsScreen(habits: habits),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(255, 238, 229, 255),
              foregroundColor: Colors.deepPurple.shade900,
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Insights'),
            ),

            const SizedBox(height: 10),

            //add action button
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
              },
              label: const Text('New Habit'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

//private widget
class _HabitCard extends ConsumerWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitNotifierProvider.notifier);

    //check habit was completed today
    final isCompletedToday = habit.isCompletedOn(DateTime.now());

    return Card(
      margin: EdgeInsets.only(bottom: 14),
      child: ListTile(
        tileColor: const Color.fromARGB(255, 246, 236, 248),
        //show emoji on left
        leading: Text(habit.emoji, style: const TextStyle(fontSize: 32)),

        //show habit name
        title: Text(habit.title, style: TextStyle(fontWeight: FontWeight.bold)),

        //show streak count
        subtitle: Text(
          'Streak: ${habit.currentStreak} days',
          style: TextStyle(
            color: habit.currentStreak > 0
                ? const Color.fromARGB(255, 228, 107, 0)
                : const Color.fromARGB(255, 70, 70, 70),
          ),
        ),

        //check button
        trailing: GestureDetector(
          onTap: () => notifier.toggleCheckIn(habit),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompletedToday ? Colors.green : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(width: 0.5),
            ),

            child: Icon(
              Icons.check,
              color: isCompletedToday ? Colors.white : Colors.grey,
            ),
          ),
        ),

        //long press to get delete option
        onLongPress: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Habit?'),
            content: Text('Are you sure you want to delete "${habit.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),

              TextButton(
                onPressed: () {
                  notifier.deleteHabit(habit.userId, habit.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
