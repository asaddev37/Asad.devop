class Batch {
  final String id;
  final String batchName;
  final String departmentId;
  final String? advisorId;

  Batch({
    required this.id,
    required this.batchName,
    required this.departmentId,
    this.advisorId,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json['id'],
    batchName: json['batch_name'],
    departmentId: json['department_id'],
    advisorId: json['advisor_id'],
  );
}