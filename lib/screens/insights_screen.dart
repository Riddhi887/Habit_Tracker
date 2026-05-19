import 'package:flutter/material.dart';
import 'package:habit_tracker/charts/habit_chart_card.dart';
import 'package:habit_tracker/models/habit.dart';

class InsightsScreen extends StatelessWidget {
  final List<Habit> habits;

  const InsightsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Insights')),
      body: habits.isEmpty
          ? const Center(child: Text('No habits to show insights'))
          : ListView.builder(
              itemCount: habits.length,
              padding: EdgeInsets.all(17),
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitChartCard(habit: habit);
              },
            ),
    );
  }
}
