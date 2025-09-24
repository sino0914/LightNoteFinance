import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final List<Summary> summaries;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final DateTime? unlockedAt;

  @HiveField(8)
  final bool isCompleted;

  Book({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.summaries,
    this.isUnlocked = false,
    this.isFavorite = false,
    this.unlockedAt,
    this.isCompleted = false,
  });

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<Summary>? summaries,
    bool? isUnlocked,
    bool? isFavorite,
    DateTime? unlockedAt,
    bool? isCompleted,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      summaries: summaries ?? this.summaries,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isFavorite: isFavorite ?? this.isFavorite,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'summaries': summaries.map((x) => x.toJson()).toList(),
      'isUnlocked': isUnlocked,
      'isFavorite': isFavorite,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Book.fromJson(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? map['cover_image'] ?? '',
      summaries: List<Summary>.from(
        map['summaries']?.map((x) => Summary.fromJson(x)) ?? [],
      ),
      isUnlocked: map['isUnlocked'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  factory Book.fromApiJson(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['cover_image'] ?? '',
      summaries: List<Summary>.from(
        map['summaries']?.map((x) => Summary.fromApiJson(x)) ?? [],
      ),
      isUnlocked: false,
      isFavorite: false,
      unlockedAt: null,
      isCompleted: false,
    );
  }
}

@HiveType(typeId: 1)
class Summary {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final int order;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final DateTime? unlockedAt;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final DateTime? readAt;

  Summary({
    required this.id,
    required this.bookId,
    required this.content,
    required this.order,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isRead = false,
    this.readAt,
  });

  Summary copyWith({
    String? id,
    String? bookId,
    String? content,
    int? order,
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return Summary(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      order: order ?? this.order,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'order': order,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory Summary.fromJson(Map<String, dynamic> map) {
    return Summary(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      content: map['content'] ?? '',
      order: map['order']?.toInt() ?? 0,
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null
          ? DateTime.parse(map['readAt'])
          : null,
    );
  }

  factory Summary.fromApiJson(Map<String, dynamic> map) {
    return Summary(
      id: map['id'] ?? '',
      bookId: map['book_id'] ?? '',
      content: map['content'] ?? '',
      order: map['order_index']?.toInt() ?? 0,
      isUnlocked: false,
      unlockedAt: null,
      isRead: false,
      readAt: null,
    );
  }
}

