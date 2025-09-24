// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      points: fields[1] as int,
      isFirstLogin: fields[2] as bool,
      lastLoginAt: fields[3] as DateTime?,
      unlockedBookIds: (fields[4] as List).cast<String>(),
      favoriteBookIds: (fields[5] as List).cast<String>(),
      currentBookId: fields[6] as String?,
      weeklyActivity: (fields[7] as Map).cast<String, bool>(),
      viewHistory: (fields[8] as List).cast<String>(),
      dailyUnlockHistory: (fields[9] as Map).cast<String, DateTime>(),
      settings: fields[10] as UserSettings,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.points)
      ..writeByte(2)
      ..write(obj.isFirstLogin)
      ..writeByte(3)
      ..write(obj.lastLoginAt)
      ..writeByte(4)
      ..write(obj.unlockedBookIds)
      ..writeByte(5)
      ..write(obj.favoriteBookIds)
      ..writeByte(6)
      ..write(obj.currentBookId)
      ..writeByte(7)
      ..write(obj.weeklyActivity)
      ..writeByte(8)
      ..write(obj.viewHistory)
      ..writeByte(9)
      ..write(obj.dailyUnlockHistory)
      ..writeByte(10)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 3;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      hasBookmarkFeature: fields[0] as bool,
      hasHighlightFeature: fields[1] as bool,
      canChooseBooks: fields[2] as bool,
      dailySummaryCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.hasBookmarkFeature)
      ..writeByte(1)
      ..write(obj.hasHighlightFeature)
      ..writeByte(2)
      ..write(obj.canChooseBooks)
      ..writeByte(3)
      ..write(obj.dailySummaryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
