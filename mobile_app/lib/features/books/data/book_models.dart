class Book {
  final int bookId;
  final String title;
  final String? author;
  final String status;
  final String ownershipType;
  final int? loanExtendedCount;
  final bool overdue;
  final int overdueDays;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    required this.status,
    required this.ownershipType,
    this.loanExtendedCount,
    this.overdue = false,
    this.overdueDays = 0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      status: json['status'] as String,
      ownershipType: json['ownershipType'] as String,
      loanExtendedCount: json['loanExtendedCount'] as int?,
      overdue: json['overdue'] as bool? ?? false,
      overdueDays: json['overdueDays'] as int? ?? 0,
    );
  }
}

class BookTransaction {
  final int id;
  final String type;
  final int? fromUserId;
  final int? toUserId;
  final String? startDate;
  final String? endDate;
  final String? note;

  BookTransaction({
    required this.id,
    required this.type,
    this.fromUserId,
    this.toUserId,
    this.startDate,
    this.endDate,
    this.note,
  });

  factory BookTransaction.fromJson(Map<String, dynamic> json) {
    return BookTransaction(
      id: json['id'] as int,
      type: json['type'] as String,
      fromUserId: json['fromUserId'] as int?,
      toUserId: json['toUserId'] as int?,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class BookDetail {
  final int bookId;
  final String title;
  final String? author;
  final String? isbn;
  final String? language;
  final String? category;
  final String? condition;
  final String? notes;
  final String ownershipType;
  final int? ownerUserId;
  final int? ownerCommunityId;
  final int? currentHolderUserId;
  final int? currentShelfId;
  final String status;
  final String? loanStartAt;
  final String? dueAt;
  final int? loanExtendedCount;
  final bool overdue;
  final int overdueDays;
  final List<BookTransaction> transactions;

  BookDetail({
    required this.bookId,
    required this.title,
    this.author,
    this.isbn,
    this.language,
    this.category,
    this.condition,
    this.notes,
    required this.ownershipType,
    this.ownerUserId,
    this.ownerCommunityId,
    this.currentHolderUserId,
    this.currentShelfId,
    required this.status,
    this.loanStartAt,
    this.dueAt,
    this.loanExtendedCount,
    required this.overdue,
    required this.overdueDays,
    required this.transactions,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    final transactionsJson = json['transactions'] as List<dynamic>? ?? [];

    return BookDetail(
      bookId: json['bookId'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      isbn: json['isbn'] as String?,
      language: json['language'] as String?,
      category: json['category'] as String?,
      condition: json['condition'] as String?,
      notes: json['notes'] as String?,
      ownershipType: json['ownershipType'] as String,
      ownerUserId: json['ownerUserId'] as int?,
      ownerCommunityId: json['ownerCommunityId'] as int?,
      currentHolderUserId: json['currentHolderUserId'] as int?,
      currentShelfId: json['currentShelfId'] as int?,
      status: json['status'] as String,
      loanStartAt: json['loanStartAt']?.toString(),
      dueAt: json['dueAt']?.toString(),
      loanExtendedCount: json['loanExtendedCount'] as int?,
      overdue: json['overdue'] as bool? ?? false,
      overdueDays: json['overdueDays'] as int? ?? 0,
      transactions: transactionsJson
          .map((item) => BookTransaction.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String? city;
  final String? email;

  UserSummary({required this.id, required this.name, this.city, this.email});

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      city: json['city'] as String?,
      email: json['email'] as String?,
    );
  }

  String displayLabel() {
    final parts = <String>[name, '#$id'];

    if (city != null && city!.trim().isNotEmpty) {
      parts.add(city!.trim());
    }

    return parts.join(' • ');
  }
}

class CommunitySummary {
  final int id;
  final String name;
  final String? description;

  CommunitySummary({required this.id, required this.name, this.description});

  factory CommunitySummary.fromJson(Map<String, dynamic> json) {
    return CommunitySummary(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
    );
  }

  String displayLabel() {
    return '$name • #$id';
  }
}
