import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_quest/core/services/firestore_service.dart';
import 'package:focus_quest/features/auth/providers/auth_provider.dart';
import 'package:focus_quest/models/app_user.dart';
import 'package:focus_quest/models/focus_session.dart';
import 'package:focus_quest/models/journal_entry.dart';
import 'package:focus_quest/models/quest.dart';
import 'package:focus_quest/models/user_progress.dart';
import 'package:focus_quest/services/sembast_service.dart';
import 'package:sembast/sembast.dart';

class SyncService {
  SyncService(this._ref);

  final Ref _ref;
  final FirestoreService _firestore = FirestoreService();
  final SembastService _sembast = SembastService();

  AppUser? get _currentUser => _ref.read(authProvider).value;
  bool get _isSyncEnabled => _currentUser?.isSyncEnabled ?? false;
  String? get _userId => _currentUser?.id;

  /// Syncs a quest to Firestore if sync is enabled.
  Future<void> syncQuest(Quest quest) async {
    if (!_isSyncEnabled || _userId == null) return;
    try {
      await _firestore.saveQuest(_userId!, quest);
    } on Exception catch (e) {
      // For now, we just log errors. In a full implementation,
      // we'd use a queue.
      debugPrint('Sync Error (Quest): $e');
    }
  }

  /// Deletes a quest from Firestore if sync is enabled.
  Future<void> syncDeleteQuest(String questId) async {
    if (!_isSyncEnabled || _userId == null) return;
    try {
      await _firestore.deleteQuest(_userId!, questId);
    } on Exception catch (e) {
      debugPrint('Sync Error (Delete Quest): $e');
    }
  }

  /// Syncs a focus session to Firestore if sync is enabled.
  Future<void> syncFocusSession(FocusSession session) async {
    if (!_isSyncEnabled || _userId == null) return;
    try {
      await _firestore.saveFocusSession(_userId!, session);
    } on Exception catch (e) {
      debugPrint('Sync Error (Focus Session): $e');
    }
  }

  /// Syncs a journal entry to Firestore if sync is enabled.
  Future<void> syncJournalEntry(JournalEntry entry) async {
    if (!_isSyncEnabled || _userId == null) return;
    try {
      await _firestore.saveJournalEntry(_userId!, entry);
    } on Exception catch (e) {
      debugPrint('Sync Error (Journal Entry): $e');
    }
  }

  /// Syncs user progress to Firestore if sync is enabled.
  Future<void> syncUserProgress(UserProgress progress) async {
    if (!_isSyncEnabled || _userId == null) return;
    try {
      await _firestore.saveUserProgress(_userId!, progress);
    } on Exception catch (e) {
      debugPrint('Sync Error (User Progress): $e');
    }
  }

  /// Syncs the user profile/settings to Firestore.
  Future<void> syncUser(AppUser user) async {
    if (user.isGuest) return;
    try {
      await _firestore.saveUser(user);
    } on Exception catch (e) {
      debugPrint('Sync Error (User): $e');
    }
  }

  /// Performs a full two-way sync between local Sembast and Firestore.
  Future<void> performFullSync() async {
    if (!_isSyncEnabled || _userId == null) return;

    debugPrint('Starting full sync for user: $_userId');

    try {
      final db = await _sembast.database;

      await Future.wait([
        _syncQuests(db),
        _syncFocusSessions(db),
        _syncJournalEntries(db),
        _syncUserProgress(db),
      ]);

      debugPrint('Full sync completed successfully');

      // We don't force a UI refresh here, but ideally we should notify the
      // notifiers that data has changed. For now, since mostly this happens
      // on startup/login, the initial load will handle it.
    } on Exception catch (e) {
      debugPrint('Full sync failed: $e');
    }
  }

  Future<void> _syncQuests(Database db) async {
    final remoteQuests = await _firestore.getQuests(_userId!);
    final localRecords = await _sembast.quests.find(db);
    final localQuests = localRecords
        .map((r) => Quest.fromJson(r.value))
        .toList();

    final localMap = {for (final q in localQuests) q.id: q};
    final remoteMap = {for (final q in remoteQuests) q.id: q};

    final allIds = {...localMap.keys, ...remoteMap.keys};

    for (final id in allIds) {
      final local = localMap[id];
      final remote = remoteMap[id];

      if (local != null && remote != null) {
        if ((local.updatedAt ?? local.createdAt).isBefore(
          remote.updatedAt ?? remote.createdAt,
        )) {
          // Remote is newer
          await _sembast.quests.record(id).put(db, remote.toJson());
        } else if ((local.updatedAt ?? local.createdAt).isAfter(
          remote.updatedAt ?? remote.createdAt,
        )) {
          // Local is newer
          await _firestore.saveQuest(_userId!, local);
        }
      } else if (local != null) {
        // Only local exists
        await _firestore.saveQuest(_userId!, local);
      } else if (remote != null) {
        // Only remote exists
        await _sembast.quests.record(id).put(db, remote.toJson());
      }
    }
  }

  Future<void> _syncFocusSessions(Database db) async {
    final remoteSessions = await _firestore.getFocusSessions(_userId!);
    final localRecords = await _sembast.focusSessions.find(db);
    final localSessions = localRecords
        .map((r) => FocusSession.fromJson(r.value))
        .toList();

    final localMap = {for (final s in localSessions) s.id: s};
    final remoteMap = {for (final s in remoteSessions) s.id: s};

    final allIds = {...localMap.keys, ...remoteMap.keys};

    for (final id in allIds) {
      final local = localMap[id];
      final remote = remoteMap[id];

      if (local != null && remote != null) {
        if ((local.updatedAt ?? local.startedAt).isBefore(
          remote.updatedAt ?? remote.startedAt,
        )) {
          await _sembast.focusSessions.record(id).put(db, remote.toJson());
        } else if ((local.updatedAt ?? local.startedAt).isAfter(
          remote.updatedAt ?? remote.startedAt,
        )) {
          await _firestore.saveFocusSession(_userId!, local);
        }
      } else if (local != null) {
        await _firestore.saveFocusSession(_userId!, local);
      } else if (remote != null) {
        await _sembast.focusSessions.record(id).put(db, remote.toJson());
      }
    }
  }

  Future<void> _syncJournalEntries(Database db) async {
    final remoteEntries = await _firestore.getJournalEntries(_userId!);
    final localRecords = await _sembast.journalEntries.find(db);
    final localEntries = localRecords
        .map((r) => JournalEntry.fromJson(r.value))
        .toList();

    final localMap = {for (final e in localEntries) e.id: e};
    final remoteMap = {for (final e in remoteEntries) e.id: e};

    final allIds = {...localMap.keys, ...remoteMap.keys};

    for (final id in allIds) {
      final local = localMap[id];
      final remote = remoteMap[id];

      if (local != null && remote != null) {
        if ((local.updatedAt ?? local.createdAt).isBefore(
          remote.updatedAt ?? remote.createdAt,
        )) {
          await _sembast.journalEntries.record(id).put(db, remote.toJson());
        } else if ((local.updatedAt ?? local.createdAt).isAfter(
          remote.updatedAt ?? remote.createdAt,
        )) {
          await _firestore.saveJournalEntry(_userId!, local);
        }
      } else if (local != null) {
        await _firestore.saveJournalEntry(_userId!, local);
      } else if (remote != null) {
        await _sembast.journalEntries.record(id).put(db, remote.toJson());
      }
    }
  }

  Future<void> _syncUserProgress(Database db) async {
    const progressId = 'default_user'; // Matches UserProgressNotifier._userId
    final remoteProgress = await _firestore.getUserProgress(_userId!);
    final localRecord = await _sembast.userProgress.record(progressId).get(db);
    final localProgress = localRecord != null
        ? UserProgress.fromJson(localRecord)
        : null;

    if (localProgress != null && remoteProgress != null) {
      if ((localProgress.updatedAt ?? localProgress.createdAt).isBefore(
        remoteProgress.updatedAt ?? remoteProgress.createdAt,
      )) {
        await _sembast.userProgress
            .record(progressId)
            .put(db, remoteProgress.toJson());
      } else if ((localProgress.updatedAt ?? localProgress.createdAt).isAfter(
        remoteProgress.updatedAt ?? remoteProgress.createdAt,
      )) {
        await _firestore.saveUserProgress(_userId!, localProgress);
      }
    } else if (localProgress != null) {
      await _firestore.saveUserProgress(_userId!, localProgress);
    } else if (remoteProgress != null) {
      await _sembast.userProgress
          .record(progressId)
          .put(db, remoteProgress.toJson());
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});
