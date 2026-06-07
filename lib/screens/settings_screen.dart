import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.04),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SETTINGS',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: const Color(0xFFFFB300),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFB300).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure targets, reminders, & explore science FAQs',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E92A0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION 1: GOAL SETTINGS
                _buildSectionTitle('Goal Thresholds'),
                const SizedBox(height: 12),
                _buildGoalsCard(context, state),

                const SizedBox(height: 24),

                // SECTION 2: REMINDERS
                _buildSectionTitle('Schedules & Reminders'),
                const SizedBox(height: 12),
                _buildRemindersCard(context),

                const SizedBox(height: 24),

                // SECTION 3: CREATINE SCIENCE FAQ
                _buildSectionTitle('Creatine Science & FAQ'),
                const SizedBox(height: 12),
                _buildFAQCard(),

                const SizedBox(height: 24),

                // SECTION 4: DATA RESET
                _buildSectionTitle('System Management'),
                const SizedBox(height: 12),
                _buildDangerZoneCard(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // GOALS CARD
  Widget _buildGoalsCard(BuildContext context, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Creatine Goal Slider
          _buildSliderSetting(
            title: 'Creatine Daily Target',
            value: state.creatineGoal,
            min: 2.0,
            max: 20.0,
            divisions: 36,
            suffix: 'g',
            activeColor: const Color(0xFF00E5FF),
            onChanged: (val) => state.updateGoals(creatine: val),
          ),
          const Divider(color: Colors.white10, height: 24),

          // Water Goal Slider
          _buildSliderSetting(
            title: 'Water Intake Target',
            value: state.hydrationGoal,
            min: 1500.0,
            max: 6000.0,
            divisions: 9, // steps of 500ml
            suffix: 'ml',
            activeColor: const Color(0xFF00C6FF),
            onChanged: (val) => state.updateGoals(hydration: val),
          ),
          const Divider(color: Colors.white10, height: 24),

          // Weight Target Box Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Body Weight',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Goal target for gym charts',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E92A0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showEditWeightGoalDialog(context, state),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2230),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        '${state.weightGoal.toStringAsFixed(1)} kg',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF8E92A0),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${value.toInt()}$suffix',
              style: GoogleFonts.outfit(
                color: activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: const Color(0xFF1E2230),
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.12),
            valueIndicatorColor: const Color(0xFF1E2230),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // REMINDERS CARD
  Widget _buildRemindersCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Color(0xFFFFB300), size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intake Reminders',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Push notification schedules',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E92A0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _remindersEnabled,
                activeColor: const Color(0xFFFFB300),
                activeTrackColor: const Color(0xFFFFB300).withOpacity(0.3),
                inactiveThumbColor: const Color(0xFF8E92A0),
                inactiveTrackColor: const Color(0xFF1E2230),
                onChanged: (val) {
                  setState(() {
                    _remindersEnabled = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E2230),
                      content: Text(
                        val ? 'Reminders enabled successfully!' : 'Reminders turned off.',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (_remindersEnabled) ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Reminder Time',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (time != null) {
                      setState(() {
                        _reminderTime = time;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E2230),
                            content: Text(
                              'Creatine intake reminder set for ${time.format(context)}!',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2230),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      _reminderTime.format(context),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // FAQ CARD
  Widget _buildFAQCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: ThemeData.dark().copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Column(
            children: [
              _buildFAQTile(
                'Why is Water so crucial with Creatine?',
                'Creatine operates by drawing water into your muscle cells (osmosis), which increases muscle cell volume and promotes protein synthesis. Because of this, your overall body requires more water. Dehydration can cause bloating, muscle cramps, and decrease the efficiency of creatine.',
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildFAQTile(
                'What is the Loading vs Maintenance Phase?',
                'Loading Phase: Taking 20 grams/day (split into 4 doses of 5g) for 5–7 days to saturate muscles rapidly, followed by 3-5g daily. \n\nMaintenance Phase: Taking 3–5g daily. Muscles take longer to saturate (about 3–4 weeks) but is just as effective and gentler on the stomach.',
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildFAQTile(
                'How does Creatine improve Gym performance?',
                'Creatine increases your muscles\' phosphocreatine stores. Phosphocreatine helps form adenosine triphosphate (ATP), the key molecule your cells use for energy and explosive activity. During workouts, ATP is broken down to produce energy. Creatine allows you to regenerate ATP faster, letting you squeeze out extra reps!',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String title, String answer) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Text(
          answer,
          style: GoogleFonts.inter(
            color: const Color(0xFFB0B4C3),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // DANGER ZONE CARD
  Widget _buildDangerZoneCard(BuildContext context, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF5252).withOpacity(0.12),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset App Data',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wipes weights, streaks, & intake logs.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E92A0),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252).withOpacity(0.12),
              foregroundColor: const Color(0xFFFF5252),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFF5252), width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _showResetDialog(context, state),
            child: Text(
              'Reset Data',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppState state) {
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
              'Are you absolutely sure?',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'This action cannot be undone. All your weight charts, gym logs, hydration records, and creatine streaks will be permanently wiped.',
              style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 13, height: 1.4),
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
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  state.clearAllData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E2230),
                      content: Text(
                        'All application data has been wiped.',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Wipe Everything',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // DIALOG FOR EDIT WEIGHT GOAL
  void _showEditWeightGoalDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.weightGoal.toString());
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
              'Set Target Weight',
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
                  'Specify your goal bodyweight in kg:',
                  style: GoogleFonts.inter(color: const Color(0xFF8E92A0), fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. 75.0',
                    hintStyle: GoogleFonts.inter(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    suffixText: 'kg',
                    suffixStyle: GoogleFonts.outfit(color: const Color(0xFFFFB300), fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFB300),
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
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null && val > 0) {
                    state.updateGoals(weight: val);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Save Target',
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
