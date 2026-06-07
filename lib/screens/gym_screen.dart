import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/app_state.dart';
import '../models/weight_log.dart';
import '../models/workout_log.dart';

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final weightLogs = state.sortedWeightLogs;
    final workouts = state.sortedWorkoutLogs;

    // Weight progress stats
    double weightChange = 0.0;
    if (weightLogs.length >= 2) {
      weightChange = weightLogs.last.weightKg - weightLogs.first.weightKg;
    }
    double weightGoalDiff = state.latestWeight - state.weightGoal;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: 100,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD400FF).withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF87).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
              physics: const BouncingScrollPhysics(),
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GYM & STATS',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: const Color(0xFFD400FF),
                            shadows: [
                              Shadow(
                                color: const Color(0xFFD400FF).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track weight trends & log workouts',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF8E92A0),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    _buildAddButton(
                      context,
                      label: 'Log Weight',
                      icon: Icons.scale_rounded,
                      color: const Color(0xFFD400FF),
                      onPressed: () => _showLogWeightDialog(context, state),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weight Progress Line Chart Card
                _buildWeightChartCard(context, weightLogs, state.weightGoal),

                const SizedBox(height: 20),

                // Weight Progress Summary HUD
                _buildWeightSummaryHUD(context, state, weightChange, weightGoalDiff),

                const SizedBox(height: 28),

                // Workouts Log Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workout Sessions',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildAddButton(
                      context,
                      label: 'Log Workout',
                      icon: Icons.add_rounded,
                      color: const Color(0xFF00FF87),
                      onPressed: () => _showAddWorkoutSheet(context, state),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Workouts list
                if (workouts.isEmpty)
                  _buildEmptyState('No workouts logged yet.', 'Time to hit the iron!')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      return _buildWorkoutCard(context, state, workouts[index]);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WEIGHT CHART CARD
  Widget _buildWeightChartCard(BuildContext context, List<WeightLog> logs, double targetWeight) {
    bool hasData = logs.length >= 2;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.only(left: 10, right: 22, top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight Journey',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Goal: ${targetWeight.toStringAsFixed(1)} kg',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hasData
                ? LineChart(
                    _buildChartData(logs),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          color: const Color(0xFFD400FF).withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Log your weight at least twice\nto render the progress chart.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF8E92A0),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(List<WeightLog> logs) {
    // Determine min/max weights to bound the graph nicely
    double minWeight = logs.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    double maxWeight = logs.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);

    // Padding min/max weights
    if (minWeight == maxWeight) {
      minWeight -= 2;
      maxWeight += 2;
    } else {
      double diff = maxWeight - minWeight;
      minWeight -= diff * 0.15;
      maxWeight += diff * 0.15;
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), logs[i].weightKg));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.04),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index >= 0 && index < logs.length) {
                final date = logs[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d/M').format(date),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E92A0),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: (maxWeight - minWeight) / 3 > 0 ? (maxWeight - minWeight) / 3 : 1.0,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  "${value.toStringAsFixed(1)}k",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (logs.length - 1).toDouble(),
      minY: minWeight,
      maxY: maxWeight,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD400FF),
              Color(0xFF7C4DFF),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: const Color(0xFFD400FF),
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD400FF).withOpacity(0.20),
                const Color(0xFF7C4DFF).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (touchedSpot) => const Color(0xFF1E2230),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((barSpot) {
              final date = logs[barSpot.x.toInt()].date;
              return LineTooltipItem(
                '${barSpot.y.toStringAsFixed(1)} kg\n',
                GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: DateFormat('MMM d, yyyy').format(date),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E92A0),
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // WEIGHT SUMMARY HUD
  Widget _buildWeightSummaryHUD(BuildContext context, AppState state, double change, double goalDiff) {
    final curWeight = state.latestWeight;
    final changeText = change == 0.0
        ? "Holding steady"
        : (change < 0 ? "${change.abs().toStringAsFixed(1)} kg dropped" : "${change.toStringAsFixed(1)} kg gained");
    
    final goalText = goalDiff == 0.0
        ? "Target Met! 🎉"
        : (goalDiff > 0 ? "${goalDiff.toStringAsFixed(1)} kg to lose" : "${goalDiff.abs().toStringAsFixed(1)} kg to gain");

    return Row(
      children: [
        Expanded(
          child: _buildHUDCard(
            'Current weight',
            curWeight > 0 ? '${curWeight.toStringAsFixed(1)} kg' : 'Not Set',
            changeText,
            curWeight > 0 ? const Color(0xFFD400FF) : const Color(0xFF8E92A0),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildHUDCard(
            'Target Progress',
            '${state.weightGoal.toStringAsFixed(1)} kg',
            goalText,
            goalDiff == 0.0 && curWeight > 0 ? const Color(0xFF00FF87) : const Color(0xFF00E5FF),
          ),
        ),
      ],
    );
  }

  Widget _buildHUDCard(String label, String value, String subtext, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF8E92A0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtext,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WORKOUT ITEM CARD
  Widget _buildWorkoutCard(BuildContext context, AppState state, WorkoutLog workout) {
    String dateStr;
    final diff = DateTime.now().difference(workout.date).inDays;
    if (diff == 0) {
      dateStr = "Today";
    } else if (diff == 1) {
      dateStr = "Yesterday";
    } else {
      dateStr = DateFormat('MMM d').format(workout.date);
    }

    Color catColor = const Color(0xFF00FF87);
    if (workout.category == 'Strength') {
      catColor = const Color(0xFFD400FF);
    } else if (workout.category == 'Cardio') {
      catColor = const Color(0xFF00E5FF);
    } else if (workout.category == 'Endurance') {
      catColor = const Color(0xFFFFB300);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: ThemeData.dark().copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(
              workout.title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor.withOpacity(0.25), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    workout.category,
                    style: GoogleFonts.inter(
                      color: catColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF8E92A0)),
                const SizedBox(width: 4),
                Text(
                  '${workout.durationMinutes} mins',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Text(
              dateStr,
              style: GoogleFonts.inter(
                color: const Color(0xFF8E92A0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            children: [
              const Divider(color: Colors.white10),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 16, color: Color(0xFF8E92A0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workout.notes.isNotEmpty ? workout.notes : "No session notes logged.",
                      style: GoogleFonts.inter(
                        color: const Color(0xFFB0B4C3),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5252),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: Text(
                      'Delete Session',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => state.deleteWorkout(workout.id),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String main, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: Colors.white.withOpacity(0.12),
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            main,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.inter(
              color: const Color(0xFF8E92A0),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.2), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // DIALOG LOG WEIGHT
  void _showLogWeightDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(
      text: state.latestWeight > 0 ? state.latestWeight.toString() : '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E2230),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            title: Text(
              'Log Today\'s Weight',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record bodyweight (kg) to map in progress charts:',
                  style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. 79.5',
                    hintStyle: GoogleFonts.inter(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    suffixText: 'kg',
                    suffixStyle: GoogleFonts.outfit(color: const Color(0xFFD400FF), fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFD400FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: const Color(0xFF8E92A0)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD400FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null && val > 0) {
                    state.addWeight(val);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Save Weight',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM SHEET FOR LOG WORKOUT
  void _showAddWorkoutSheet(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'Strength';
    double duration = 45;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2230),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Log New Gym Session',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title field
                      Text(
                        'Session Title / Muscle Split',
                        style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. Pull Day (Back/Biceps)',
                          hintStyle: GoogleFonts.inter(color: Colors.white24),
                          filled: true,
                          fillColor: const Color(0xFF131722),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Category selection
                      Text(
                        'Training Focus',
                        style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Strength', 'Hypertrophy', 'Cardio', 'Endurance'].map((cat) {
                          final isSelected = category == cat;
                          Color themeColor = const Color(0xFF00FF87);
                          if (cat == 'Strength') themeColor = const Color(0xFFD400FF);
                          if (cat == 'Cardio') themeColor = const Color(0xFF00E5FF);
                          if (cat == 'Endurance') themeColor = const Color(0xFFFFB300);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setModalState(() => category = cat),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected ? themeColor.withOpacity(0.15) : const Color(0xFF131722),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? themeColor : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.inter(
                                      color: isSelected ? themeColor : const Color(0xFF8E92A0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Duration slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Duration (minutes)',
                            style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${duration.toInt()} mins',
                            style: GoogleFonts.outfit(color: const Color(0xFF00FF87), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF00FF87),
                          inactiveTrackColor: const Color(0xFF131722),
                          thumbColor: const Color(0xFF00FF87),
                          overlayColor: const Color(0xFF00FF87).withOpacity(0.12),
                          valueIndicatorColor: const Color(0xFF1E2230),
                        ),
                        child: Slider(
                          value: duration,
                          min: 5,
                          max: 180,
                          divisions: 35,
                          onChanged: (val) {
                            setModalState(() {
                              duration = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Notes field
                      Text(
                        'Session Notes (Exercises, weight lift records, etc.)',
                        style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. Squat 3x5 at 100kg. Pull-ups felt clean...',
                          hintStyle: GoogleFonts.inter(color: Colors.white24),
                          filled: true,
                          fillColor: const Color(0xFF131722),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF00FF87).withOpacity(0.3),
                          ),
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              state.addWorkout(
                                titleController.text,
                                category,
                                duration.toInt(),
                                notesController.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Save Workout Session',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
