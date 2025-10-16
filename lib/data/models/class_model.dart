class ClassModel {
  final String id;
  final String name;
  final String teacherId;
  final List<String> studentIds;
  final DateTime createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentIds,
    required this.createdAt,
  });

  factory ClassModel.fromMap(String id, Map<String, dynamic> data) {
    return ClassModel(
      id: id,
      name: (data['name'] ?? '') as String,
      teacherId: (data['teacherId'] ?? '') as String,
      studentIds: ((data['studentIds'] as List?)?.map((e) => e.toString()).toList()) ?? const [],
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt']?['millisecondsSinceEpoch'] ?? 0) as int,
              isUtc: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
