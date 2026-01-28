class OrdenCreateResponse {
  final int id;
  const OrdenCreateResponse({required this.id});

  factory OrdenCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrdenCreateResponse(id: (json['id'] as num).toInt());
  }
}
