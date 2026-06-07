import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    // Dynamic greetings based on time
    final hour = DateTime.now().hour;
    String greeting = "Crush Your Day";
    if (hour < 12) {
      greeting = "Morning Champ";
    } else if (hour < 17) {
      greeting = "Fuel the Pump";
    } else {
      greeting = "Evening Grind";
    }

    final creatinePercent = (state.todayCreatine / state.creatineGoal).clamp(0.0, 1.0);
    final hydrationPercent = (state.todayHydration / state.hydrationGoal).clamp(0.0, 1.0);

    // Checklist statuses
    final bool creatineMet = state.todayCreatine >= state.creatineGoal;
    final bool hydrationMet = state.todayHydration >= state.hydrationGoal;
    final bool weightLogged = state.weightLogs.any((w) =>
        w.date.year == DateTime.now().year &&
        w.date.month == DateTime.now().month &&
        w.date.day == DateTime.now().day);
    final bool workoutLogged = state.workoutLogs.any((w) =>
        w.date.year == DateTime.now().year &&
        w.date.month == DateTime.now().month &&
        w.date.day == DateTime.now().day);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD400FF).withOpacity(0.08),
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
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KREAFLOW',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: const Color(0xFF00E5FF),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF8E92A0),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Streak badge
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF5722).withOpacity(0.15),
                            const Color(0xFFFF9800).withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF7A00).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5722).withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFF7A00),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.currentStreak} Day Streak',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFAC64),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Welcome card
                Text(
                  greeting,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Keep your creatine saturated and muscles hydrated today.",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Creatine Progress Card (Fancy Ring)
                _buildCreatineCard(context, state, creatinePercent),
                
                const SizedBox(height: 20),
                
                // Hydration Progress Card (Wave Bar)
                _buildHydrationCard(context, state, hydrationPercent),
                
                const SizedBox(height: 20),
                
                // Daily Checklist & Stats Quick View
                _buildChecklistCard(context, creatineMet, hydrationMet, weightLogged, workoutLogged),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CREATINE CARD
  Widget _buildCreatineCard(BuildContext context, AppState state, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.03),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creatine Tracker',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daily Target: ${state.creatineGoal}g',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E92A0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.opacity_rounded,
                  color: Color(0xFF00E5FF),
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Center Ring and Numbers
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background track
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),
                        // Progress track
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                        // Inner Text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.todayCreatine.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 28,
                                  fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'of ${state.creatineGoal}g',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8E92A0),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Text indicator on the right
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress >= 1.0 ? 'Saturated! 🔥' : 'Replenish Now',
                      style: GoogleFonts.outfit(
                        color: progress >= 1.0 ? const Color(0xFF00FF87) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      progress >= 1.0
                          ? 'Daily muscles saturation level is fully loaded. Great job!'
                          : 'Creatine helps build ATP for explosive workout energy. Take your scoop!',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E92A0),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Log Buttons
          Row(
            children: [
              Expanded(
                child: _buildLogButton(
                  label: '+1g Quick Log',
                  color: const Color(0xFF00E5FF),
                  onPressed: () => state.addCreatine(1.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLogButton(
                  label: '+5g Scoop',
                  color: const Color(0xFF00E5FF),
                  isPrimary: true,
                  onPressed: () => state.addCreatine(5.0),
                ),
              ),
              const SizedBox(width: 10),
              // Custom add button
              _buildRoundActionButton(
                icon: Icons.add_rounded,
                color: const Color(0xFF00E5FF),
                onPressed: () => _showCustomLogDialog(context, state, isCreatine: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HYDRATION CARD
  Widget _buildHydrationCard(BuildContext context, AppState state, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0055FF).withOpacity(0.03),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Water & Hydration',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Creatine requires high water intake',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E92A0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF00BFFF),
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 18),
          
          // Progress bar and info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.todayHydration.toInt()} ml / ${state.hydrationGoal.toInt()} ml',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Met',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Custom Styled Linear Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Stack(
                children: [
                  Container(
                    color: Colors.white.withOpacity(0.04),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0072FF),
                            Color(0xFF00C6FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quick logging water presets
          Row(
            children: [
              Expanded(
                child: _buildLogButton(
                  label: '+250ml',
                  color: const Color(0xFF00C6FF),
                  onPressed: () => state.addHydration(250.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLogButton(
                  label: '+500ml',
                  color: const Color(0xFF00C6FF),
                  onPressed: () => state.addHydration(500.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLogButton(
                  label: '+1L Bottle',
                  color: const Color(0xFF00C6FF),
                  isPrimary: true,
                  onPressed: () => state.addHydration(1000.0),
                ),
              ),
              const SizedBox(width: 8),
              _buildRoundActionButton(
                icon: Icons.add_rounded,
                color: const Color(0xFF00C6FF),
                onPressed: () => _showCustomLogDialog(context, state, isCreatine: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CHECKLIST CARD
  Widget _buildChecklistCard(
      BuildContext context, bool creatine, bool hydration, bool weight, bool workout) {
    int tasksMet = (creatine ? 1 : 0) + (hydration ? 1 : 0) + (weight ? 1 : 0) + (workout ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Muscle Checklist",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$tasksMet / 4 Done",
                style: GoogleFonts.inter(
                  color: tasksMet == 4 ? const Color(0xFF00FF87) : const Color(0xFF8E92A0),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCheckItem("Saturate Creatine Goal", creatine, const Color(0xFF00E5FF)),
          _buildCheckItem("Hit Water Intake Goal", hydration, const Color(0xFF00C6FF)),
          _buildCheckItem("Log Today's Bodyweight", weight, const Color(0xFFD400FF)),
          _buildCheckItem("Perform & Log Gym Session", workout, const Color(0xFFFFB300)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, bool isDone, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone ? activeColor.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone ? activeColor : const Color(0xFF323645),
                width: 2,
              ),
            ),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    color: activeColor,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: isDone ? Colors.white : const Color(0xFF8E92A0),
              fontSize: 14,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  // SHARED BUTTON BUILDERS
  Widget _buildLogButton({
    required String label,
    required Color color,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : color,
          elevation: isPrimary ? 8 : 0,
          shadowColor: isPrimary ? color.withOpacity(0.4) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : BorderSide(color: color.withOpacity(0.35), width: 1.5),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 24,
      ),
    );
  }

  // DIALOG FOR CUSTOM INPUT
  void _showCustomLogDialog(BuildContext context, AppState state, {required bool isCreatine}) {
    final controller = TextEditingController();
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
              isCreatine ? 'Custom Creatine Log' : 'Custom Water Log',
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
                  isCreatine
                      ? 'Enter the amount of creatine in grams:'
                      : 'Enter the amount of water in ml:',
                  style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isCreatine ? 'e.g. 3.5' : 'e.g. 750',
                    hintStyle: GoogleFonts.inter(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    suffixText: isCreatine ? 'g' : 'ml',
                    suffixStyle: GoogleFonts.outfit(color: isCreatine ? const Color(0xFF00E5FF) : const Color(0xFF00C6FF), fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isCreatine ? const Color(0xFF00E5FF) : const Color(0xFF00C6FF),
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
                  backgroundColor: isCreatine ? const Color(0xFF00E5FF) : const Color(0xFF00C6FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null && val > 0) {
                    if (isCreatine) {
                      state.addCreatine(val);
                    } else {
                      state.addHydration(val);
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Log',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
