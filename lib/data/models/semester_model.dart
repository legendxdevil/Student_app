import 'package:student_app/data/models/subject_model.dart';

class SemesterModel {
  final int? id;
  final int semesterNumber;
  final String semesterName;
  final double? sgpa;
  final double? totalCredits;
  final double? completedCredits;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SemesterModel({
    this.id,
    required this.semesterNumber,
    required this.semesterName,
    this.sgpa,
    this.totalCredits,
    this.completedCredits,
    this.startDate,
    this.endDate,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester_number': semesterNumber,
      'semester_name': semesterName,
      'sgpa': sgpa,
      'total_credits': totalCredits,
      'completed_credits': completedCredits,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as int?,
      semesterNumber: json['semester_number'] as int,
      semesterName: json['semester_name'] as String,
      sgpa: json['sgpa'] as double?,
      totalCredits: json['total_credits'] as double?,
      completedCredits: json['completed_credits'] as double?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isCompleted: (json['is_completed'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  SemesterModel copyWith({
    int? id,
    int? semesterNumber,
    String? semesterName,
    double? sgpa,
    double? totalCredits,
    double? completedCredits,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      semesterName: semesterName ?? this.semesterName,
      sgpa: sgpa ?? this.sgpa,
      totalCredits: totalCredits ?? this.totalCredits,
      completedCredits: completedCredits ?? this.completedCredits,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate SGPA from subjects
  double calculateSGPA(List<SubjectModel> subjects) {
    if (subjects.isEmpty) return 0.0;
    
    double totalGradePoints = 0;
    double totalCredits = 0;
    
    for (var subject in subjects) {
      if (subject.gradePoints != null && subject.credits > 0) {
        totalGradePoints += subject.gradePoints! * subject.credits;
        totalCredits += subject.credits;
      }
    }
    
    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }
}
