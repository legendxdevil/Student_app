import 'package:student_app/data/models/subject_model.dart';

class CGPAService {
  // Grade to Grade Points mapping for 10-point scale
  static const Map<String, double> gradeScale10Point = {
    'O': 10.0,  // Outstanding
    'A+': 9.0,  // Excellent
    'A': 8.0,   // Very Good
    'B+': 7.0,  // Good
    'B': 6.0,   // Above Average
    'C': 5.0,   // Average
    'P': 4.0,   // Pass
    'F': 0.0,   // Fail
  };

  // Grade to Grade Points mapping for 4-point scale
  static const Map<String, double> gradeScale4Point = {
    'A': 4.0,
    'B': 3.0,
    'C': 2.0,
    'D': 1.0,
    'F': 0.0,
  };

  // Calculate SGPA for a semester
  static double calculateSGPA(List<SubjectModel> subjects) {
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

  // Calculate CGPA across all semesters
  static double calculateCGPA(List<Map<String, dynamic>> semesterData) {
    if (semesterData.isEmpty) return 0.0;

    double totalGradePoints = 0;
    double totalCredits = 0;

    for (var data in semesterData) {
      final sgpa = data['sgpa'] as double?;
      final credits = data['credits'] as double?;
      
      if (sgpa != null && credits != null && credits > 0) {
        totalGradePoints += sgpa * credits;
        totalCredits += credits;
      }
    }

    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }

  // Convert marks to grade points (10-point scale)
  static double marksToGradePoints10(double marks, double maxMarks) {
    final percentage = (marks / maxMarks) * 100;
    
    if (percentage >= 90) return 10.0;
    if (percentage >= 80) return 9.0;
    if (percentage >= 70) return 8.0;
    if (percentage >= 60) return 7.0;
    if (percentage >= 50) return 6.0;
    if (percentage >= 45) return 5.0;
    if (percentage >= 40) return 4.0;
    return 0.0;
  }

  // Convert marks to grade (10-point scale)
  static String marksToGrade10(double marks, double maxMarks) {
    final percentage = (marks / maxMarks) * 100;
    
    if (percentage >= 90) return 'O';
    if (percentage >= 80) return 'A+';
    if (percentage >= 70) return 'A';
    if (percentage >= 60) return 'B+';
    if (percentage >= 50) return 'B';
    if (percentage >= 45) return 'C';
    if (percentage >= 40) return 'P';
    return 'F';
  }

  // Convert marks to grade points (4-point scale)
  static double marksToGradePoints4(double marks, double maxMarks) {
    final percentage = (marks / maxMarks) * 100;
    
    if (percentage >= 90) return 4.0;
    if (percentage >= 80) return 3.0;
    if (percentage >= 70) return 2.0;
    if (percentage >= 60) return 1.0;
    return 0.0;
  }

  // Convert marks to grade (4-point scale)
  static String marksToGrade4(double marks, double maxMarks) {
    final percentage = (marks / maxMarks) * 100;
    
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Get grade from grade points
  static String gradePointsToGrade(double gradePoints, String scale) {
    if (scale == '10_point') {
      return gradeScale10Point.entries
          .firstWhere((entry) => entry.value == gradePoints, orElse: () => const MapEntry('F', 0.0))
          .key;
    } else {
      return gradeScale4Point.entries
          .firstWhere((entry) => entry.value == gradePoints, orElse: () => const MapEntry('F', 0.0))
          .key;
    }
  }

  // Get grade points from grade
  static double? gradeToGradePoints(String grade, String scale) {
    if (scale == '10_point') {
      return gradeScale10Point[grade.toUpperCase()];
    } else {
      return gradeScale4Point[grade.toUpperCase()];
    }
  }

  // Calculate total credits for subjects
  static double calculateTotalCredits(List<SubjectModel> subjects) {
    return subjects.fold(0, (sum, subject) => sum + subject.credits);
  }

  // Calculate completed credits (subjects with grades)
  static double calculateCompletedCredits(List<SubjectModel> subjects) {
    return subjects
        .where((s) => s.gradePoints != null)
        .fold(0, (sum, subject) => sum + subject.credits);
  }

  // Get performance classification based on CGPA
  static String getPerformanceClassification(double cgpa, String scale) {
    if (scale == '10_point') {
      if (cgpa >= 9.0) return 'Outstanding';
      if (cgpa >= 8.0) return 'Excellent';
      if (cgpa >= 7.0) return 'Very Good';
      if (cgpa >= 6.0) return 'Good';
      if (cgpa >= 5.0) return 'Above Average';
      if (cgpa >= 4.0) return 'Average';
      return 'Below Average';
    } else {
      if (cgpa >= 3.7) return 'Outstanding';
      if (cgpa >= 3.3) return 'Excellent';
      if (cgpa >= 3.0) return 'Very Good';
      if (cgpa >= 2.7) return 'Good';
      if (cgpa >= 2.0) return 'Average';
      return 'Below Average';
    }
  }

  // Calculate percentage from CGPA (customizable formula)
  static double cgpaToPercentage(double cgpa, {String formula = 'default'}) {
    switch (formula) {
      case 'mumbai_university':
        // Mumbai University: Percentage = (CGPA * 7.1) + 11
        return (cgpa * 7.1) + 11;
      case 'anna_university':
        // Anna University: Percentage = CGPA * 10
        return cgpa * 10;
      case 'vtu':
        // VTU: Percentage = (CGPA - 0.75) * 10
        return (cgpa - 0.75) * 10;
      case 'gtu':
        // GTU: Percentage = (CGPA - 0.5) * 10
        return (cgpa - 0.5) * 10;
      default:
        // Default: Percentage = CGPA * 9.5
        return cgpa * 9.5;
    }
  }

  // Get available conversion formulas
  static Map<String, String> getConversionFormulas() {
    return {
      'default': 'Default (CGPA × 9.5)',
      'mumbai_university': 'Mumbai University (CGPA × 7.1 + 11)',
      'anna_university': 'Anna University (CGPA × 10)',
      'vtu': 'VTU ((CGPA - 0.75) × 10)',
      'gtu': 'GTU ((CGPA - 0.5) × 10)',
    };
  }
}
