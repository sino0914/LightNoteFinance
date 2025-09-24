import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../models/purchase_item.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(SummaryAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(PurchaseItemAdapter());
    Hive.registerAdapter(PurchaseItemTypeAdapter());

    await Hive.openBox<User>(HiveBoxNames.userBox);
    await Hive.openBox<List<dynamic>>(HiveBoxNames.booksBox);
    await Hive.openBox<List<dynamic>>(HiveBoxNames.summariesBox);
    await Hive.openBox(HiveBoxNames.settingsBox);
  }

  Future<User?> getUser() async {
    final box = Hive.box<User>(HiveBoxNames.userBox);
    if (box.isNotEmpty) {
      return box.getAt(0);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    final box = Hive.box<User>(HiveBoxNames.userBox);
    if (box.isEmpty) {
      await box.add(user);
    } else {
      await box.putAt(0, user);
    }
  }

  Future<List<Book>> getBooks() async {
    final box = Hive.box<List<dynamic>>(HiveBoxNames.booksBox);
    if (box.isNotEmpty) {
      final data = box.getAt(0);
      if (data != null) {
        return data.cast<Book>();
      }
    }
    return [];
  }

  Future<void> saveBooks(List<Book> books) async {
    final box = Hive.box<List<dynamic>>(HiveBoxNames.booksBox);
    if (box.isEmpty) {
      await box.add(books);
    } else {
      await box.putAt(0, books);
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final box = Hive.box(HiveBoxNames.settingsBox);
    return Map<String, dynamic>.from(box.toMap());
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(HiveBoxNames.settingsBox);
    await box.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    final box = Hive.box(HiveBoxNames.settingsBox);
    return box.get(key) as T?;
  }

  Future<void> clearAllData() async {
    await Hive.box<User>(HiveBoxNames.userBox).clear();
    await Hive.box<List<dynamic>>(HiveBoxNames.booksBox).clear();
    await Hive.box<List<dynamic>>(HiveBoxNames.summariesBox).clear();
    await Hive.box(HiveBoxNames.settingsBox).clear();
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}