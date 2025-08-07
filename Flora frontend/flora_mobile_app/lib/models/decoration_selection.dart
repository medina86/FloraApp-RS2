class DecorationSelection {
  final int id;
  final int decorationRequestId;
  final int decorationSuggestionId;
  final int userId;
  final String? comments;
  final DateTime createdAt;
  final String status;

  DecorationSelection({
    required this.id,
    required this.decorationRequestId,
    required this.decorationSuggestionId,
    required this.userId,
    this.comments,
    required this.createdAt,
    required this.status,
  });

  factory DecorationSelection.fromJson(Map<String, dynamic> json) {
    return DecorationSelection(
      id: json['id'],
      decorationRequestId: json['decorationRequestId'],
      decorationSuggestionId: json['decorationSuggestionId'],
      userId: json['userId'],
      comments: json['comments'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decorationRequestId': decorationRequestId,
      'decorationSuggestionId': decorationSuggestionId,
      'userId': userId,
      'comments': comments,
    };
  }
}
