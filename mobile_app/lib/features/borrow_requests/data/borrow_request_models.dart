class BorrowRequestItem {
  final int requestId;
  final int? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final int? requesterUserId;
  final String? requesterUserName;
  final String status;
  final String? message;
  final String? rejectionReason;
  final String? decisionNote;
  final int? decidedByUserId;
  final String? decidedByUserName;
  final String? decidedAt;
  final String? createdAt;
  final String? updatedAt;

  const BorrowRequestItem({
    required this.requestId,
    this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.requesterUserId,
    this.requesterUserName,
    required this.status,
    this.message,
    this.rejectionReason,
    this.decisionNote,
    this.decidedByUserId,
    this.decidedByUserName,
    this.decidedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BorrowRequestItem.fromJson(Map<String, dynamic> json) {
    return BorrowRequestItem(
      requestId: _asInt(json['requestId'] ?? json['id']) ?? 0,
      bookId: _asInt(json['bookId']),
      bookTitle: _asNullableString(json['bookTitle'] ?? json['title']),
      bookAuthor: _asNullableString(json['bookAuthor'] ?? json['author']),
      requesterUserId: _asInt(json['requesterUserId'] ?? json['requesterId']),
      requesterUserName: _asNullableString(
        json['requesterUserName'] ?? json['requesterName'],
      ),
      status: (_asNullableString(json['status']) ?? 'UNKNOWN').trim(),
      message: _asNullableString(json['message']),
      rejectionReason: _asNullableString(json['rejectionReason']),
      decisionNote: _asNullableString(json['decisionNote']),
      decidedByUserId: _asInt(json['decidedByUserId']),
      decidedByUserName: _asNullableString(json['decidedByUserName']),
      decidedAt: _asNullableString(json['decidedAt']),
      createdAt: _asNullableString(json['createdAt']),
      updatedAt: _asNullableString(json['updatedAt']),
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isFulfilled => status == 'FULFILLED';

  String get titleOrFallback {
    if (bookTitle != null && bookTitle!.trim().isNotEmpty) {
      return bookTitle!.trim();
    }

    if (bookId != null) {
      return 'Book #$bookId';
    }

    return 'Unknown book';
  }

  String get requesterLabel {
    if (requesterUserName != null && requesterUserName!.trim().isNotEmpty) {
      if (requesterUserId != null) {
        return '${requesterUserName!.trim()} • #$requesterUserId';
      }
      return requesterUserName!.trim();
    }

    if (requesterUserId != null) {
      return 'User #$requesterUserId';
    }

    return 'Unknown requester';
  }
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
