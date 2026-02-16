class SubjectModel {
  final int? id;
  final int semesterId;
  final String name;
  final String? code;
  final double credits;
  final double? marksObtained;
  final double maxMarks;
  final String? grade;
  final double? gradePoints;
  final bool isBacklog;
  final double? attendancePercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubjectModel({
    this.id,
    required this.semesterId,
    required this.name,
    this.code,
    required this.credits,
    this.marksObtained,
    this.maxMarks = 100,
    this.grade,
    this.gradePoints,
    this.isBacklog = false,
    this.attendancePercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester_id': semesterId,
      'name': name,
      'code': code,
      'credits': credits,
      'marks_obtained': marksObtained,
      'max_marks': maxMarks,
      'grade': grade,
      'grade_points': gradePoints,
      'is_backlog': isBacklog ? 1 : 0,
      'attendance_percentage': attendancePercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int?,
      semesterId: json['semester_id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      credits: json['credits'] as double,
      marksObtained: json['marks_obtained'] as double?,
      maxMarks: json['max_marks'] as double? ?? 100,
      grade: json['grade'] as String?,
      gradePoints: json['grade_points'] as double?,
      isBacklog: (json['is_backlog'] as int? ?? 0) == 1,
      attendancePercentage: json['attendance_percentage'] as double?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  SubjectModel copyWith({
    int? id,
    int? semesterId,
    String? name,
    String? code,
    double? credits,
    double? marksObtained,
    double? maxMarks,
    String? grade,
    double? gradePoints,
    bool? isBacklog,
    double? attendancePercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      marksObtained: marksObtained ?? this.marksObtained,
      maxMarks: maxMarks ?? this.maxMarks,
      grade: grade ?? this.grade,
      gradePoints: gradePoints ?? this.gradePoints,
      isBacklog: isBacklog ?? this.isBacklog,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate percentage from marks
  double? get percentage {
    if (marksObtained == null || maxMarks <= 0) return null;
    return (marksObtained! / maxMarks) * 100;
  }
}
