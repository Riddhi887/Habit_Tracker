import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

class HabitChartCard extends StatelessWidget {
  final Habit habit;
  const HabitChartCard({super.key, required this.habit});

  //male list of last 7 days
  List<DateTime> _getLast7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });
  }

  //to get if habit was done on given day
  // chart take double value: 1.0 done else 0.0
  double _wasCompletedOn(DateTime day) {
    return habit.isCompletedOn(day) ? 1.0 : 0.0;
  }

  //labels
  String _dayLabel(DateTime day) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[day.weekday - 1];
  }

  double _safeValue(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final last7Days = _getLast7Days();

    final streak = last7Days.reversed
        .takeWhile((day) => habit.isCompletedOn(day))
        .length;

    final double barHeight = streak > 0 ? streak.toDouble() : 1.0;
    final double maxY = barHeight + 1; // +1 gives breathing room at top

    final barColor = streak > 0 ? Colors.deepPurple : Colors.grey;
    final barGroups = List.generate(7, (i) {
      final day = last7Days[i];
      final completed = _wasCompletedOn(day); // 1.0 or 0.0

      return BarChartGroupData(
        x: i, // x position: 0 (Mon/oldest) → 6 (today)
        barRods: [
          BarChartRodData(
            toY: _safeValue(completed == 1.0 ? barHeight : 0.0), // bar height
            width: 22, // bar width in pixels
            borderRadius: BorderRadius.circular(6), // rounded top corners
            color: completed == 1.0
                ? Colors.deepPurple
                : const Color.fromARGB(255, 174, 154, 214),
          ),
        ],
      );
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //header section
            Row(
              children: [
                Text(habit.emoji, style: TextStyle(fontSize: 28)),

                const SizedBox(width: 10),

                Column(
                  //name + streak info
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    //streak info row
                    Row(
                      children: [
                        Text(
                          '🔥 $streak day streak',
                          style: TextStyle(
                            fontSize: 13,
                            // streak color used here too — everything matches
                            color: streak > 0 ? barColor : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                //BAR CHART
                // ── BAR CHART ─────────────────────────────────────
                Expanded(
                  child: SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        maxY: maxY,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final day = last7Days[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _dayLabel(day),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
