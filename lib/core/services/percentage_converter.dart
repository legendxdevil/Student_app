import 'package:student_app/core/services/percentage_service.dart';

/// A utility class for converting between different grading systems
class PercentageConverter {
  /// Convert percentage to grade based on 10-point scale
  static String percentageToGrade10(double percentage) {
    return PercentageService.getGrade10Point(percentage);
  }

  /// Convert percentage to grade based on 4-point scale
  static String percentageToGrade4(double percentage) {
    return PercentageService.getGrade4Point(percentage);
  }

  /// Convert percentage to grade points (10-point scale)
  static double percentageToGradePoints10(double percentage) {
    if (percentage >= 90) return 10.0;
    if (percentage >= 80) return 9.0;
    if (percentage >= 70) return 8.0;
    if (percentage >= 60) return 7.0;
    if (percentage >= 50) return 6.0;
    if (percentage >= 45) return 5.0;
    if (percentage >= 40) return 4.0;
    return 0.0;
  }

  /// Convert percentage to grade points (4-point scale)
  static double percentageToGradePoints4(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 80) return 3.0;
    if (percentage >= 70) return 2.0;
    if (percentage >= 60) return 1.0;
    return 0.0;
  }

  /// Convert CGPA to percentage using specified formula
  static double cgpaToPercentage(
    double cgpa, {
    String formula = 'default',
  }) {
    return PercentageService.cgpaToPercentage(cgpa, formula: formula);
  }

  /// Convert percentage to CGPA
  static double percentageToCGPA(
    double percentage, {
    String formula = 'default',
  }) {
    return PercentageService.percentageToCGPA(percentage, formula: formula);
  }

  /// Calculate marks needed to achieve target percentage
  static double calculateRequiredMarks({
    required double targetPercentage,
    required double maxMarks,
    double? currentMarks,
  }) {
    return PercentageService.calculateRequiredMarks(
      targetPercentage,
      maxMarks,
      currentMarks: currentMarks,
    );
  }

  /// Get classification based on percentage
  static String getClassification(double percentage) {
    return PercentageService.getClassification(percentage);
  }
}
