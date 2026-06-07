import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/creatine_log.dart';
import '../models/hydration_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _activeTab = 0; // 0 for Creatine, 1 for Hydration

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF87).withOpacity(0.04),
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
                      'HISTORY TRACK',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: const Color(0xFF00FF87),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00FF87).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review daily consumption map & logs',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E92A0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Custom Segmented tab control
                _buildSegmentedControl(),

                const SizedBox(height: 24),

                // 21-Day Status Grid
                _activeTab == 0
                    ? _buildStatusGrid(state, isCreatine: true)
                    : _buildStatusGrid(state, isCreatine: false),

                const SizedBox(height: 28),

                // Chronological logs title
                Text(
                  _activeTab == 0 ? 'Creatine Intake Logs' : 'Hydration Intake Logs',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Logs list
                _activeTab == 0
                    ? _buildCreatineLogsList(state)
                    : _buildHydrationLogsList(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? const Color(0xFF1E2230) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.opacity_rounded,
                      color: _activeTab == 0 ? const Color(0xFF00E5FF) : const Color(0xFF8E92A0),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Creatine',
                      style: GoogleFonts.outfit(
                        color: _activeTab == 0 ? Colors.white : const Color(0xFF8E92A0),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? const Color(0xFF1E2230) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      color: _activeTab == 1 ? const Color(0xFF00C6FF) : const Color(0xFF8E92A0),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Water',
                      style: GoogleFonts.outfit(
                        color: _activeTab == 1 ? Colors.white : const Color(0xFF8E92A0),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STATUS GRID
  Widget _buildStatusGrid(AppState state, {required bool isCreatine}) {
    final now = DateTime.now();
    final gridItems = List.generate(21, (index) {
      // Return date backwards from today (e.g. index 0 is 20 days ago, index 20 is today)
      return now.subtract(Duration(days: 20 - index));
    });

    final themeColor = isCreatine ? const Color(0xFF00E5FF) : const Color(0xFF00C6FF);
    final target = isCreatine ? state.creatineGoal : state.hydrationGoal;

    // Map daily totals
    Map<String, double> totals = {};
    if (isCreatine) {
      for (var log in state.creatineLogs) {
        final key = _normalizeDate(log.date);
        totals[key] = (totals[key] ?? 0.0) + log.amountGrams;
      }
    } else {
      for (var log in state.hydrationLogs) {
        final key = _normalizeDate(log.date);
        totals[key] = (totals[key] ?? 0.0) + log.amountMl;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCreatine ? '21-Day Saturation Map' : '21-Day Hydration Map',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: gridItems.length,
            itemBuilder: (context, index) {
              final date = gridItems[index];
              final key = _normalizeDate(date);
              final total = totals[key] ?? 0.0;
              final percent = total / target;

              // Design square status
              BoxDecoration decoration;
              if (percent >= 1.0) {
                // Goal Met (Solid glowing neon)
                decoration = BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.4),
                      blurRadius: 6,
                    )
                  ],
                );
              } else if (percent > 0.0) {
                // Incomplete / Partial (outlined colored border)
                decoration = BoxDecoration(
                  color: themeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: themeColor.withOpacity(0.7),
                    width: 1.5,
                  ),
                );
              } else {
                // Not taken / Unlogged (grey outline grid box)
                decoration = BoxDecoration(
                  color: Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                    width: 1.5,
                  ),
                );
              }

              final bool isToday = key == _normalizeDate(now);

              return Tooltip(
                message: "${DateFormat('MMM d').format(date)}: ${isCreatine ? '${total.toStringAsFixed(1)}g' : '${total.toInt()}ml'}",
                child: Container(
                  decoration: decoration,
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: GoogleFonts.outfit(
                      color: percent >= 1.0
                          ? Colors.black
                          : (isToday ? themeColor : const Color(0xFF8E92A0)),
                      fontSize: 12,
                      fontWeight: isToday || percent >= 1.0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 18),
          
          // Map legends
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegend('Missed', Colors.white.withOpacity(0.06), hasBorder: true),
              const SizedBox(width: 12),
              _buildLegend('Partial', themeColor.withOpacity(0.12), borderColor: themeColor.withOpacity(0.7)),
              const SizedBox(width: 12),
              _buildLegend('100% Met', themeColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, {bool hasBorder = false, Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder
                ? Border.all(color: Colors.white.withOpacity(0.12))
                : (borderColor != null ? Border.all(color: borderColor) : null),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF8E92A0),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // CREATINE LOGS LIST
  Widget _buildCreatineLogsList(AppState state) {
    final logs = state.sortedCreatineLogs;
    if (logs.isEmpty) {
      return _buildEmptyState('No creatine logs recorded.', 'Tap + on the Dashboard to begin.');
    }

    // Group logs by day to display aggregate sum
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF131722).withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.opacity_rounded,
                      color: Color(0xFF00E5FF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(log.date),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(log.date),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E92A0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '+${log.amountGrams.toStringAsFixed(1)} g',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // WATER LOGS LIST
  Widget _buildHydrationLogsList(AppState state) {
    final logs = state.hydrationLogs; // Already has logs
    final sorted = List<HydrationLog>.from(logs)..sort((a, b) => b.date.compareTo(a.date));

    if (sorted.isEmpty) {
      return _buildEmptyState('No hydration logs recorded.', 'Keep your water high for safety!');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final log = sorted[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF131722).withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C6FF).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF00C6FF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(log.date),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(log.date),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E92A0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '+${log.amountMl.toInt()} ml',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00C6FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
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
            Icons.history_toggle_off_rounded,
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

  String _normalizeDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
