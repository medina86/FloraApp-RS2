class PagedResult<T> {
  final List<T> items;
  final int? totalCount;

  PagedResult({required this.items, this.totalCount});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult<T>(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {'items': items.map(toJsonT).toList(), 'totalCount': totalCount};
  }
}
