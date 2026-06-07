import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/creatine_log.dart';
import '../models/hydration_log.dart';
import '../models/workout_log.dart';
import '../models/weight_log.dart';

class AppState extends ChangeNotifier {
  static const String _creatineGoalKey = 'creatine_goal';
  static const String _hydrationGoalKey = 'hydration_goal';
  static const String _weightGoalKey = 'weight_goal';
  static const String _creatineLogsKey = 'creatine_logs';
  static const String _hydrationLogsKey = 'hydration_logs';
  static const String _workoutLogsKey = 'workout_logs';
  static const String _weightLogsKey = 'weight_logs';

  double creatineGoal = 5.0; // in grams
  double hydrationGoal = 3500.0; // in ml
  double weightGoal = 75.0; // in kg

  List<CreatineLog> creatineLogs = [];
  List<HydrationLog> hydrationLogs = [];
  List<WorkoutLog> workoutLogs = [];
  List<WeightLog> weightLogs = [];

  bool isInitialized = false;

  AppState() {
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load goals
    creatineGoal = prefs.getDouble(_creatineGoalKey) ?? 5.0;
    hydrationGoal = prefs.getDouble(_hydrationGoalKey) ?? 3500.0;
    weightGoal = prefs.getDouble(_weightGoalKey) ?? 75.0;

    // Load logs
    final String? creatineJson = prefs.getString(_creatineLogsKey);
    final String? hydrationJson = prefs.getString(_hydrationLogsKey);
    final String? workoutJson = prefs.getString(_workoutLogsKey);
    final String? weightJson = prefs.getString(_weightLogsKey);

    if (creatineJson != null) {
      try {
        final List decoded = jsonDecode(creatineJson);
        creatineLogs = decoded.map((e) => CreatineLog.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading creatine logs: $e");
      }
    }

    if (hydrationJson != null) {
      try {
        final List decoded = jsonDecode(hydrationJson);
        hydrationLogs = decoded.map((e) => HydrationLog.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading hydration logs: $e");
      }
    }

    if (workoutJson != null) {
      try {
        final List decoded = jsonDecode(workoutJson);
        workoutLogs = decoded.map((e) => WorkoutLog.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading workout logs: $e");
      }
    }

    if (weightJson != null) {
      try {
        final List decoded = jsonDecode(weightJson);
        weightLogs = decoded.map((e) => WeightLog.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading weight logs: $e");
      }
    }

    // Populate mock data if this is the first run and everything is empty
    if (creatineLogs.isEmpty && hydrationLogs.isEmpty && workoutLogs.isEmpty && weightLogs.isEmpty) {
      await _loadMockData(prefs);
    }

    isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadMockData(SharedPreferences prefs) async {
    final now = DateTime.now();

    // 1. Weight Logs (showing down-trend progress)
    weightLogs = [
      WeightLog(date: now.subtract(const Duration(days: 9)), weightKg: 82.5),
      WeightLog(date: now.subtract(const Duration(days: 7)), weightKg: 82.1),
      WeightLog(date: now.subtract(const Duration(days: 5)), weightKg: 81.7),
      WeightLog(date: now.subtract(const Duration(days: 3)), weightKg: 81.3),
      WeightLog(date: now.subtract(const Duration(days: 1)), weightKg: 80.8),
    ];
    await prefs.setString(_weightLogsKey, jsonEncode(weightLogs.map((e) => e.toJson()).toList()));

    // 2. Creatine Logs (taken for 8 of the last 10 days, creating a streak of 6 days up to yesterday)
    creatineLogs = [
      CreatineLog(date: now.subtract(const Duration(days: 9)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 8)), amountGrams: 5.0),
      // Day 7 missed
      CreatineLog(date: now.subtract(const Duration(days: 6)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 5)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 4)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 3)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 2)), amountGrams: 5.0),
      CreatineLog(date: now.subtract(const Duration(days: 1)), amountGrams: 5.0),
      // Today is empty to let the user log it themselves!
    ];
    await prefs.setString(_creatineLogsKey, jsonEncode(creatineLogs.map((e) => e.toJson()).toList()));

    // 3. Hydration Logs (taking water daily, 3000-4000ml)
    hydrationLogs = [
      HydrationLog(date: now.subtract(const Duration(days: 9)), amountMl: 3200),
      HydrationLog(date: now.subtract(const Duration(days: 8)), amountMl: 3500),
      HydrationLog(date: now.subtract(const Duration(days: 7)), amountMl: 3000),
      HydrationLog(date: now.subtract(const Duration(days: 6)), amountMl: 3600),
      HydrationLog(date: now.subtract(const Duration(days: 5)), amountMl: 3800),
      HydrationLog(date: now.subtract(const Duration(days: 4)), amountMl: 3500),
      HydrationLog(date: now.subtract(const Duration(days: 3)), amountMl: 3400),
      HydrationLog(date: now.subtract(const Duration(days: 2)), amountMl: 4000),
      HydrationLog(date: now.subtract(const Duration(days: 1)), amountMl: 3700),
      HydrationLog(date: now, amountMl: 1000), // Today partially hydrated
    ];
    await prefs.setString(_hydrationLogsKey, jsonEncode(hydrationLogs.map((e) => e.toJson()).toList()));

    // 4. Workout Logs
    workoutLogs = [
      WorkoutLog(
        id: '1',
        date: now.subtract(const Duration(days: 8)),
        title: 'Push Day (Chest, Shoulders & Tri)',
        category: 'Strength',
        durationMinutes: 65,
        notes: 'Incline bench press felt very stable. 4 sets of 8 reps at 80kg.',
      ),
      WorkoutLog(
        id: '2',
        date: now.subtract(const Duration(days: 6)),
        title: 'Pull Day (Back & Biceps Focus)',
        category: 'Hypertrophy',
        durationMinutes: 70,
        notes: 'Weighted pull-ups 3 sets of 6 reps. Crazy pump in biceps.',
      ),
      WorkoutLog(
        id: '3',
        date: now.subtract(const Duration(days: 4)),
        title: 'Leg Day (Quads & Calves)',
        category: 'Strength',
        durationMinutes: 75,
        notes: 'Squats: 5x5 at 110kg. Finished with leg extensions and calf raises.',
      ),
      WorkoutLog(
        id: '4',
        date: now.subtract(const Duration(days: 2)),
        title: 'Upper Body Pump Session',
        category: 'Hypertrophy',
        durationMinutes: 60,
        notes: 'Supersets. Lowered rest times. Great mind-muscle connection.',
      ),
    ];
    await prefs.setString(_workoutLogsKey, jsonEncode(workoutLogs.map((e) => e.toJson()).toList()));
  }

  // Helper date normalizer
  String _normalizeDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --- GETTERS FOR STATS ---

  double get todayCreatine {
    final todayStr = _normalizeDate(DateTime.now());
    return creatineLogs
        .where((log) => _normalizeDate(log.date) == todayStr)
        .fold(0.0, (sum, log) => sum + log.amountGrams);
  }

  double get todayHydration {
    final todayStr = _normalizeDate(DateTime.now());
    return hydrationLogs
        .where((log) => _normalizeDate(log.date) == todayStr)
        .fold(0.0, (sum, log) => sum + log.amountMl);
  }

  double get latestWeight {
    if (weightLogs.isEmpty) return 0.0;
    // Sort logs descending by date
    final sorted = List<WeightLog>.from(weightLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.weightKg;
  }

  int get currentStreak {
    if (creatineLogs.isEmpty) return 0;

    // Group logs by date
    Map<String, double> dailyTotals = {};
    for (var log in creatineLogs) {
      String dateStr = _normalizeDate(log.date);
      dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0.0) + log.amountGrams;
    }

    DateTime checkDate = DateTime.now();
    String todayStr = _normalizeDate(checkDate);
    String yesterdayStr = _normalizeDate(checkDate.subtract(const Duration(days: 1)));

    double todayTotal = dailyTotals[todayStr] ?? 0.0;
    double yesterdayTotal = dailyTotals[yesterdayStr] ?? 0.0;

    DateTime startDate;
    if (todayTotal >= creatineGoal) {
      startDate = checkDate;
    } else if (yesterdayTotal >= creatineGoal) {
      startDate = checkDate.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    DateTime dateToVerify = startDate;
    while (true) {
      String verifyStr = _normalizeDate(dateToVerify);
      double dayTotal = dailyTotals[verifyStr] ?? 0.0;
      if (dayTotal >= creatineGoal) {
        streak++;
        dateToVerify = dateToVerify.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get maxStreak {
    if (creatineLogs.isEmpty) return 0;

    // Group logs by date
    Map<String, double> dailyTotals = {};
    List<String> uniqueDates = [];
    for (var log in creatineLogs) {
      String dateStr = _normalizeDate(log.date);
      if (!dailyTotals.containsKey(dateStr)) {
        uniqueDates.add(dateStr);
      }
      dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0.0) + log.amountGrams;
    }

    if (uniqueDates.isEmpty) return 0;

    // Sort dates
    uniqueDates.sort();

    int maxS = 0;
    int currentS = 0;
    DateTime? prevDate;

    for (var dateStr in uniqueDates) {
      DateTime date = DateTime.parse(dateStr);
      double total = dailyTotals[dateStr] ?? 0.0;

      if (total >= creatineGoal) {
        if (prevDate == null) {
          currentS = 1;
        } else {
          int diffDays = date.difference(prevDate).inDays;
          if (diffDays == 1) {
            currentS++;
          } else if (diffDays > 1) {
            if (currentS > maxS) maxS = currentS;
            currentS = 1;
          }
        }
        prevDate = date;
      } else {
        if (currentS > maxS) maxS = currentS;
        currentS = 0;
        prevDate = null;
      }
    }
    if (currentS > maxS) maxS = currentS;
    return maxS;
  }

  List<WeightLog> get sortedWeightLogs {
    final list = List<WeightLog>.from(weightLogs);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<WorkoutLog> get sortedWorkoutLogs {
    final list = List<WorkoutLog>.from(workoutLogs);
    list.sort((a, b) => b.date.compareTo(a.date)); // Recent first
    return list;
  }

  List<CreatineLog> get sortedCreatineLogs {
    final list = List<CreatineLog>.from(creatineLogs);
    list.sort((a, b) => b.date.compareTo(a.date)); // Recent first
    return list;
  }

  // --- ACTIONS ---

  Future<void> addCreatine(double grams, {DateTime? date}) async {
    final logDate = date ?? DateTime.now();
    creatineLogs.add(CreatineLog(date: logDate, amountGrams: grams));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_creatineLogsKey, jsonEncode(creatineLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addHydration(double ml, {DateTime? date}) async {
    final logDate = date ?? DateTime.now();
    
    // If logging for today, we can just aggregate or add separate entry
    hydrationLogs.add(HydrationLog(date: logDate, amountMl: ml));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hydrationLogsKey, jsonEncode(hydrationLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addWorkout(String title, String category, int duration, String notes, {DateTime? date}) async {
    final logDate = date ?? DateTime.now();
    final newWorkout = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: logDate,
      title: title,
      category: category,
      durationMinutes: duration,
      notes: notes,
    );
    workoutLogs.add(newWorkout);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutLogsKey, jsonEncode(workoutLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> deleteWorkout(String id) async {
    workoutLogs.removeWhere((w) => w.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutLogsKey, jsonEncode(workoutLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addWeight(double weight, {DateTime? date}) async {
    final logDate = date ?? DateTime.now();
    
    // Check if there is already a weight log for the exact date (same day). If so, update it.
    final dateStr = _normalizeDate(logDate);
    final index = weightLogs.indexWhere((log) => _normalizeDate(log.date) == dateStr);

    if (index >= 0) {
      weightLogs[index] = WeightLog(date: logDate, weightKg: weight);
    } else {
      weightLogs.add(WeightLog(date: logDate, weightKg: weight));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightLogsKey, jsonEncode(weightLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> deleteWeight(WeightLog log) async {
    weightLogs.remove(log);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightLogsKey, jsonEncode(weightLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> updateGoals({double? creatine, double? hydration, double? weight}) async {
    final prefs = await SharedPreferences.getInstance();
    if (creatine != null) {
      creatineGoal = creatine;
      await prefs.setDouble(_creatineGoalKey, creatine);
    }
    if (hydration != null) {
      hydrationGoal = hydration;
      await prefs.setDouble(_hydrationGoalKey, hydration);
    }
    if (weight != null) {
      weightGoal = weight;
      await prefs.setDouble(_weightGoalKey, weight);
    }
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    creatineLogs.clear();
    hydrationLogs.clear();
    workoutLogs.clear();
    weightLogs.clear();
    creatineGoal = 5.0;
    hydrationGoal = 3500.0;
    weightGoal = 75.0;
    notifyListeners();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}

