class StudentModel {
  final int? id;
  final String name;
  final String? course;
  final String? institution;
  final String academicSystem; // 'cgpa', 'percentage', 'grade'
  final String? gradeScale; // '10_point', '4_point', 'custom'
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    this.id,
    required this.name,
    this.course,
    this.institution,
    required this.academicSystem,
    this.gradeScale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'institution': institution,
      'academic_system': academicSystem,
      'grade_scale': gradeScale,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      course: json['course'] as String?,
      institution: json['institution'] as String?,
      academicSystem: json['academic_system'] as String,
      gradeScale: json['grade_scale'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  StudentModel copyWith({
    int? id,
    String? name,
    String? course,
    String? institution,
    String? academicSystem,
    String? gradeScale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      course: course ?? this.course,
      institution: institution ?? this.institution,
      academicSystem: academicSystem ?? this.academicSystem,
      gradeScale: gradeScale ?? this.gradeScale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
