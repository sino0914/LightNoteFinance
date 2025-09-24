import 'package:hive/hive.dart';

part 'purchase_item.g.dart';

@HiveType(typeId: 4)
enum PurchaseItemType {
  @HiveField(0)
  bookmarkFeature,
  @HiveField(1)
  highlightFeature,
  @HiveField(2)
  chooseBooks,
  @HiveField(3)
  extraDailySummary,
  @HiveField(4)
  watchAd,
}

@HiveType(typeId: 5)
class PurchaseItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int price;

  @HiveField(4)
  final PurchaseItemType type;

  @HiveField(5)
  final bool isAvailable;

  @HiveField(6)
  final String? iconPath;

  PurchaseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    this.isAvailable = true,
    this.iconPath,
  });

  PurchaseItem copyWith({
    String? id,
    String? title,
    String? description,
    int? price,
    PurchaseItemType? type,
    bool? isAvailable,
    String? iconPath,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last,
      'isAvailable': isAvailable,
      'iconPath': iconPath,
    };
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toInt() ?? 0,
      type: PurchaseItemType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PurchaseItemType.bookmarkFeature,
      ),
      isAvailable: map['isAvailable'] ?? true,
      iconPath: map['iconPath'],
    );
  }
}