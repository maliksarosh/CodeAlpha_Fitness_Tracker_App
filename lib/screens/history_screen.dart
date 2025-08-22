import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_app/models/activity.dart' as app_activity;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentMonthName = DateFormat('MMMM').format(DateTime.now());
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Please log in to see your history.")));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Activity History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('activities')
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activity data to display.'));
          }

          final allActivities = snapshot.data!.docs
              .map((doc) => app_activity.Activity.fromFirestore(doc))
              .toList();
          final now = DateTime.now();
          final monthlyActivities = allActivities.where((activity) {
            final activityDate = activity.date.toDate();
            return activityDate.year == now.year &&
                activityDate.month == now.month;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Summary for $currentMonthName',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              if (monthlyActivities.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No activities logged this month.'),
                  ),
                )
              else
                SizedBox(
                  height: 300,
                  child: BarChartCard(activities: monthlyActivities),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BarChartCard extends StatelessWidget {
  final List<app_activity.Activity> activities;
  const BarChartCard({super.key, required this.activities});

  int get daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE FIX ---
    // We check the theme brightness here to use different colors.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color axisTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color gridColor = isDarkMode ? Colors.grey : Colors.grey;
    final Color borderColor = isDarkMode ? Colors.grey : Colors.grey;

    return Card(
      // The card's color will now be correct in both themes.
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    isDarkMode ? Colors.grey.shade800 : Colors.black,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final minutes = rod.toY.toInt();
                  return BarTooltipItem(
                    '$minutes min',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => _leftTitleWidgets(value,
                          meta, context, axisTextColor))), // Pass the color
              bottomTitles: AxisTitles(
                  sideTitles:
                      _bottomTitles(context, axisTextColor)), // Pass the color
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: gridColor, strokeWidth: 1);
                }),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1.5),
                left: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
            barGroups: _generateBarGroups(context),
          ),
        ),
      ),
    );
  }

  Map<int, double> get _groupedData {
    final Map<int, double> data = {};
    for (var activity in activities) {
      final dayOfMonth = activity.date.toDate().day;
      data[dayOfMonth] = (data[dayOfMonth] ?? 0) + activity.duration;
    }
    return data;
  }

  List<BarChartGroupData> _generateBarGroups(BuildContext context) {
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final totalDuration = _groupedData[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: totalDuration,
            color: Theme.of(context).hintColor,
            width: 5,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  double _calculateMaxY() {
    if (_groupedData.isEmpty) return 30;
    final maxDuration = _groupedData.values.reduce((a, b) => a > b ? a : b);
    return (maxDuration * 1.2).ceilToDouble().clamp(30, double.infinity);
  }

  Widget _leftTitleWidgets(
      double value, TitleMeta meta, BuildContext context, Color textColor) {
    if (value == meta.max || value == 0) return Container();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text('${value.toInt()}m',
          style: TextStyle(color: textColor, fontSize: 12)),
    );
  }

  SideTitles _bottomTitles(BuildContext context, Color textColor) => SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          if (value.toInt() % 5 != 0) {
            return Container();
          }
          return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8.0,
              child: Text(value.toInt().toString(),
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)));
        },
      );
}
