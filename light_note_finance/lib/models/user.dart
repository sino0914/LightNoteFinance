import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int points;

  @HiveField(2)
  final bool isFirstLogin;

  @HiveField(3)
  final DateTime? lastLoginAt;

  @HiveField(4)
  final List<String> unlockedBookIds;

  @HiveField(5)
  final List<String> favoriteBookIds;

  @HiveField(6)
  final String? currentBookId;

  @HiveField(7)
  final Map<String, bool> weeklyActivity;

  @HiveField(8)
  final List<String> viewHistory;

  @HiveField(9)
  final Map<String, DateTime> dailyUnlockHistory;

  @HiveField(10)
  final UserSettings settings;

  User({
    required this.id,
    this.points = 0,
    this.isFirstLogin = true,
    this.lastLoginAt,
    this.unlockedBookIds = const [],
    this.favoriteBookIds = const [],
    this.currentBookId,
    this.weeklyActivity = const {},
    this.viewHistory = const [],
    this.dailyUnlockHistory = const {},
    required this.settings,
  });

  User copyWith({
    String? id,
    int? points,
    bool? isFirstLogin,
    DateTime? lastLoginAt,
    List<String>? unlockedBookIds,
    List<String>? favoriteBookIds,
    String? currentBookId,
    Map<String, bool>? weeklyActivity,
    List<String>? viewHistory,
    Map<String, DateTime>? dailyUnlockHistory,
    UserSettings? settings,
  }) {
    return User(
      id: id ?? this.id,
      points: points ?? this.points,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      unlockedBookIds: unlockedBookIds ?? this.unlockedBookIds,
      favoriteBookIds: favoriteBookIds ?? this.favoriteBookIds,
      currentBookId: currentBookId ?? this.currentBookId,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      viewHistory: viewHistory ?? this.viewHistory,
      dailyUnlockHistory: dailyUnlockHistory ?? this.dailyUnlockHistory,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'isFirstLogin': isFirstLogin,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'unlockedBookIds': unlockedBookIds,
      'favoriteBookIds': favoriteBookIds,
      'currentBookId': currentBookId,
      'weeklyActivity': weeklyActivity,
      'viewHistory': viewHistory,
      'dailyUnlockHistory': dailyUnlockHistory.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'settings': settings.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      points: map['points']?.toInt() ?? 0,
      isFirstLogin: map['isFirstLogin'] ?? true,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      unlockedBookIds: List<String>.from(map['unlockedBookIds'] ?? []),
      favoriteBookIds: List<String>.from(map['favoriteBookIds'] ?? []),
      currentBookId: map['currentBookId'],
      weeklyActivity: Map<String, bool>.from(map['weeklyActivity'] ?? {}),
      viewHistory: List<String>.from(map['viewHistory'] ?? []),
      dailyUnlockHistory: Map<String, DateTime>.from(
        map['dailyUnlockHistory']?.map(
              (key, value) => MapEntry(key, DateTime.parse(value)),
            ) ??
            {},
      ),
      settings: UserSettings.fromJson(map['settings'] ?? {}),
    );
  }
}

@HiveType(typeId: 3)
class UserSettings {
  @HiveField(0)
  final bool hasBookmarkFeature;

  @HiveField(1)
  final bool hasHighlightFeature;

  @HiveField(2)
  final bool canChooseBooks;

  @HiveField(3)
  final int dailySummaryCount;

  UserSettings({
    this.hasBookmarkFeature = false,
    this.hasHighlightFeature = false,
    this.canChooseBooks = false,
    this.dailySummaryCount = 10,
  });

  UserSettings copyWith({
    bool? hasBookmarkFeature,
    bool? hasHighlightFeature,
    bool? canChooseBooks,
    int? dailySummaryCount,
  }) {
    return UserSettings(
      hasBookmarkFeature: hasBookmarkFeature ?? this.hasBookmarkFeature,
      hasHighlightFeature: hasHighlightFeature ?? this.hasHighlightFeature,
      canChooseBooks: canChooseBooks ?? this.canChooseBooks,
      dailySummaryCount: dailySummaryCount ?? this.dailySummaryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasBookmarkFeature': hasBookmarkFeature,
      'hasHighlightFeature': hasHighlightFeature,
      'canChooseBooks': canChooseBooks,
      'dailySummaryCount': dailySummaryCount,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> map) {
    return UserSettings(
      hasBookmarkFeature: map['hasBookmarkFeature'] ?? false,
      hasHighlightFeature: map['hasHighlightFeature'] ?? false,
      canChooseBooks: map['canChooseBooks'] ?? false,
      dailySummaryCount: map['dailySummaryCount']?.toInt() ?? 10,
    );
  }
}