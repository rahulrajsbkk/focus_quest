import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_quest/core/services/notification_service.dart';
import 'package:focus_quest/models/focus_session.dart';
import 'package:focus_quest/models/quest.dart';
import 'package:focus_quest/services/sembast_service.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

/// Default pomodoro durations
class PomodoroDefaults {
  static const Duration focusDuration = Duration(minutes: 25);
  static const Duration shortBreakDuration = Duration(minutes: 5);
  static const Duration longBreakDuration = Duration(minutes: 15);
  static const int sessionsBeforeLongBreak = 4;
}

/// State for the focus/timer feature
class FocusState {
  const FocusState({
    this.currentSession,
    this.sessionHistory = const [],
    this.completedSessionsToday = 0,
    this.totalFocusTimeToday = Duration.zero,
    this.isLoading = false,
    this.error,
    this.selectedQuestId,
    this.selectedQuest,
    this.focusDuration = PomodoroDefaults.focusDuration,
    this.shortBreakDuration = PomodoroDefaults.shortBreakDuration,
    this.longBreakDuration = PomodoroDefaults.longBreakDuration,
  });

  final FocusSession? currentSession;
  final List<FocusSession> sessionHistory;
  final int completedSessionsToday;
  final Duration totalFocusTimeToday;
  final bool isLoading;
  final String? error;
  final String? selectedQuestId;
  final Quest? selectedQuest;
  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;

  bool get hasActiveSession =>
      currentSession != null &&
      (currentSession!.isActive || currentSession!.isPaused);

  bool get isTimerRunning => currentSession?.isActive ?? false;
  bool get isTimerPaused => currentSession?.isPaused ?? false;

  FocusState copyWith({
    FocusSession? currentSession,
    bool clearCurrentSession = false,
    List<FocusSession>? sessionHistory,
    int? completedSessionsToday,
    Duration? totalFocusTimeToday,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedQuestId,
    bool clearSelectedQuestId = false,
    Quest? selectedQuest,
    bool clearSelectedQuest = false,
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
  }) {
    return FocusState(
      currentSession: clearCurrentSession
          ? null
          : (currentSession ?? this.currentSession),
      sessionHistory: sessionHistory ?? this.sessionHistory,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      totalFocusTimeToday: totalFocusTimeToday ?? this.totalFocusTimeToday,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedQuestId: clearSelectedQuestId
          ? null
          : (selectedQuestId ?? this.selectedQuestId),
      selectedQuest: clearSelectedQuest
          ? null
          : (selectedQuest ?? this.selectedQuest),
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
    );
  }
}

/// Notifier for managing focus session state
class FocusSessionNotifier extends Notifier<FocusState>
    with WidgetsBindingObserver {
  @override
  FocusState build() {
    // Schedule loading of history after build
    unawaited(Future.microtask(_loadSessionHistory));

    // Register as observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Clean up when provider is disposed
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _stopTicking();
      _backgroundAlertTimer?.cancel();
    });

    return const FocusState();
  }

  final SembastService _db = SembastService();
  final Uuid _uuid = const Uuid();
  Timer? _tickTimer;
  Timer? _backgroundAlertTimer;
  DateTime? _backgroundStartTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onBackground();
    } else if (state == AppLifecycleState.resumed) {
      _onForeground();
    }
  }

  void _onBackground() {
    if (state.isTimerRunning &&
        state.currentSession?.type == FocusSessionType.focus) {
      _backgroundStartTime = DateTime.now();
      _backgroundAlertTimer?.cancel();
      _backgroundAlertTimer = Timer(const Duration(minutes: 2), () {
        if (_backgroundStartTime != null) {
          unawaited(
            NotificationService().showAlert(
              title: 'Focus Alert!',
              body: "You've been out of the app for 2 minutes. Stay focused!",
            ),
          );
        }
      });
    }
  }

  void _onForeground() {
    _backgroundStartTime = null;
    _backgroundAlertTimer?.cancel();
  }

  /// Load today's session history
  Future<void> _loadSessionHistory() async {
    try {
      state = state.copyWith(isLoading: true);

      final db = await _db.database;
      final records = await _db.focusSessions.find(db);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final sessions =
          records
              .map(
                (RecordSnapshot<String, Map<String, Object?>> record) =>
                    FocusSession.fromJson(
                      Map<String, dynamic>.from(record.value),
                    ),
              )
              .toList()
            ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      final todaySessions = sessions
          .where(
            (s) =>
                s.startedAt.isAfter(todayStart) &&
                s.type == FocusSessionType.focus &&
                s.status == FocusSessionStatus.completed,
          )
          .toList();

      final completedToday = todaySessions.length;
      final totalTimeToday = todaySessions.fold<Duration>(
        Duration.zero,
        (total, session) => total + session.elapsedDuration,
      );

      // Check for active session that might have been interrupted
      final activeSession = sessions
          .where((s) => s.isActive || s.isPaused)
          .cast<FocusSession?>()
          .firstOrNull;

      state = state.copyWith(
        sessionHistory: sessions
            .where((s) => s.startedAt.isAfter(todayStart))
            .toList(),
        completedSessionsToday: completedToday,
        totalFocusTimeToday: totalTimeToday,
        currentSession: activeSession,
        isLoading: false,
        clearError: true,
      );

      if (activeSession != null) {
        _startTicking();
      }
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load sessions: $e',
      );
    }
  }

  /// Start a new focus session
  Future<void> startFocusSession({
    String? questId,
    Quest? quest,
    Duration? customDuration,
  }) async {
    if (state.hasActiveSession) {
      return; // Already have an active session
    }

    final session = FocusSession.start(
      id: _uuid.v4(),
      plannedDuration: customDuration ?? state.focusDuration,
      questId: questId ?? state.selectedQuestId,
    );

    try {
      final db = await _db.database;
      await _db.focusSessions.record(session.id).put(db, session.toJson());

      state = state.copyWith(
        currentSession: session,
        selectedQuestId: questId,
        selectedQuest: quest,
        clearError: true,
      );

      _startTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to start session: $e');
    }
  }

  /// Start a break session
  Future<void> startBreakSession({bool isLongBreak = false}) async {
    if (state.hasActiveSession) {
      return;
    }

    final breakDuration = isLongBreak
        ? state.longBreakDuration
        : state.shortBreakDuration;
    final breakType = isLongBreak
        ? FocusSessionType.longBreak
        : FocusSessionType.shortBreak;

    final session = FocusSession.start(
      id: _uuid.v4(),
      plannedDuration: breakDuration,
      type: breakType,
    );

    try {
      final db = await _db.database;
      await _db.focusSessions.record(session.id).put(db, session.toJson());

      state = state.copyWith(
        currentSession: session,
        clearError: true,
      );

      _startTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to start break: $e');
    }
  }

  /// Pause the current session
  Future<void> pauseSession() async {
    final session = state.currentSession;
    if (session == null || !session.isActive) return;

    final pausedSession = session.pause();

    try {
      final db = await _db.database;
      await _db.focusSessions
          .record(pausedSession.id)
          .put(db, pausedSession.toJson());

      state = state.copyWith(currentSession: pausedSession);
      _stopTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to pause session: $e');
    }
  }

  /// Resume a paused session
  Future<void> resumeSession() async {
    final session = state.currentSession;
    if (session == null || !session.isPaused) return;

    final resumedSession = session.resume();

    try {
      final db = await _db.database;
      await _db.focusSessions
          .record(resumedSession.id)
          .put(db, resumedSession.toJson());

      state = state.copyWith(currentSession: resumedSession);
      _startTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to resume session: $e');
    }
  }

  /// Complete the current session
  Future<void> completeSession({String? notes}) async {
    final session = state.currentSession;
    if (session == null) return;

    final completedSession = session.complete(notes: notes);

    try {
      final db = await _db.database;
      await _db.focusSessions
          .record(completedSession.id)
          .put(db, completedSession.toJson());

      // Update stats if it was a focus session
      var completedToday = state.completedSessionsToday;
      var totalTimeToday = state.totalFocusTimeToday;

      if (completedSession.type == FocusSessionType.focus) {
        completedToday++;
        totalTimeToday += completedSession.elapsedDuration;
      }

      state = state.copyWith(
        clearCurrentSession: true,
        sessionHistory: [completedSession, ...state.sessionHistory],
        completedSessionsToday: completedToday,
        totalFocusTimeToday: totalTimeToday,
      );

      _stopTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to complete session: $e');
    }
  }

  /// Cancel/interrupt the current session
  Future<void> cancelSession() async {
    final session = state.currentSession;
    if (session == null) return;

    final interruptedSession = session.interrupt();

    try {
      final db = await _db.database;
      await _db.focusSessions
          .record(interruptedSession.id)
          .put(db, interruptedSession.toJson());

      state = state.copyWith(
        clearCurrentSession: true,
        clearSelectedQuestId: true,
        clearSelectedQuest: true,
        sessionHistory: [interruptedSession, ...state.sessionHistory],
      );

      _stopTicking();
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to cancel session: $e');
    }
  }

  /// Set the quest for the next focus session
  void selectQuest(Quest? quest) {
    state = state.copyWith(
      selectedQuestId: quest?.id,
      selectedQuest: quest,
      clearSelectedQuestId: quest == null,
      clearSelectedQuest: quest == null,
    );
  }

  /// Update focus duration setting
  void setFocusDuration(Duration duration) {
    state = state.copyWith(focusDuration: duration);
  }

  /// Update short break duration setting
  void setShortBreakDuration(Duration duration) {
    state = state.copyWith(shortBreakDuration: duration);
  }

  /// Update long break duration setting
  void setLongBreakDuration(Duration duration) {
    state = state.copyWith(longBreakDuration: duration);
  }

  /// Get time logged for a specific quest today
  Future<Duration> getTimeLoggedForQuest(String questId) async {
    final db = await _db.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final finder = Finder(
      filter: Filter.and([
        Filter.equals('questId', questId),
        Filter.equals('status', FocusSessionStatus.completed.name),
        Filter.equals('type', FocusSessionType.focus.name),
        Filter.greaterThan('startedAt', todayStart.toIso8601String()),
      ]),
    );

    final records = await _db.focusSessions.find(db, finder: finder);
    final sessions = records.map(
      (r) => FocusSession.fromJson(Map<String, dynamic>.from(r.value)),
    );

    return sessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.elapsedDuration,
    );
  }

  /// Get all sessions for a specific quest today
  Future<List<FocusSession>> getSessionsForQuest(String questId) async {
    final db = await _db.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final finder = Finder(
      filter: Filter.and([
        Filter.equals('questId', questId),
        Filter.greaterThan('startedAt', todayStart.toIso8601String()),
      ]),
      sortOrders: [SortOrder('startedAt', false)],
    );

    final records = await _db.focusSessions.find(db, finder: finder);
    return records
        .map((r) => FocusSession.fromJson(Map<String, dynamic>.from(r.value)))
        .toList();
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Trigger a state update to refresh UI
      if (state.currentSession != null) {
        state = state.copyWith();

        // Auto-complete when time is up
        if (state.currentSession!.remainingDuration == Duration.zero &&
            state.currentSession!.isActive) {
          final endedType = state.currentSession!.type;
          unawaited(completeSession());

          if (endedType == FocusSessionType.shortBreak) {
            unawaited(
              NotificationService().showAlert(
                title: 'Break Ended!',
                body: 'Time to get back to work!',
              ),
            );
          }
        }
      }
    });
  }

  void _stopTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  @override
  bool updateShouldNotify(FocusState previous, FocusState next) => true;
}

/// Provider for focus session state
final focusSessionProvider = NotifierProvider<FocusSessionNotifier, FocusState>(
  FocusSessionNotifier.new,
);

/// Provider for getting time logged on a specific quest today
// ignore: specify_nonobvious_property_types
final questTimeLoggedProvider = FutureProvider.family<Duration, String>((
  ref,
  questId,
) async {
  final notifier = ref.watch(focusSessionProvider.notifier);
  return notifier.getTimeLoggedForQuest(questId);
});

/// Provider for getting all sessions for a specific quest today
// ignore: specify_nonobvious_property_types
final questSessionsProvider = FutureProvider.family<List<FocusSession>, String>(
  (ref, questId) async {
    final notifier = ref.watch(focusSessionProvider.notifier);
    return notifier.getSessionsForQuest(questId);
  },
);
