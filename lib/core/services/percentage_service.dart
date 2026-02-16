class PercentageService {
  // Calculate percentage from marks
  static double calculatePercentage(double marksObtained, double totalMarks) {
    if (totalMarks <= 0) return 0.0;
    return (marksObtained / totalMarks) * 100;
  }

  // Calculate overall percentage from multiple subjects
  static double calculateOverallPercentage(
    List<Map<String, dynamic>> subjects, {
    bool weightedByCredits = false,
  }) {
    if (subjects.isEmpty) return 0.0;

    double totalPercentage = 0;
    double totalWeight = 0;

    for (var subject in subjects) {
      final marks = subject['marks'] as double;
      final maxMarks = subject['maxMarks'] as double;
      final credits = subject['credits'] as double? ?? 1.0;

      final percentage = calculatePercentage(marks, maxMarks);

      if (weightedByCredits) {
        totalPercentage += percentage * credits;
        totalWeight += credits;
      } else {
        totalPercentage += percentage;
        totalWeight += 1;
      }
    }

    return totalWeight > 0 ? totalPercentage / totalWeight : 0.0;
  }

  // Convert CGPA to Percentage with various formulas
  static double cgpaToPercentage(
    double cgpa, {
    String formula = 'default',
    double multiplier = 9.5,
    double offset = 0,
  }) {
    switch (formula) {
      case 'mumbai_university':
        return (cgpa * 7.1) + 11;
      case 'anna_university':
        return cgpa * 10;
      case 'vtu':
        return (cgpa - 0.75) * 10;
      case 'gtu':
        return (cgpa - 0.5) * 10;
      case 'custom':
        return (cgpa * multiplier) + offset;
      default:
        return cgpa * 9.5;
    }
  }

  // Convert Percentage to CGPA (reverse calculation)
  static double percentageToCGPA(
    double percentage, {
    String formula = 'default',
    double multiplier = 9.5,
    double offset = 0,
  }) {
    switch (formula) {
      case 'mumbai_university':
        return (percentage - 11) / 7.1;
      case 'anna_university':
        return percentage / 10;
      case 'vtu':
        return (percentage / 10) + 0.75;
      case 'gtu':
        return (percentage / 10) + 0.5;
      case 'custom':
        return (percentage - offset) / multiplier;
      default:
        return percentage / 9.5;
    }
  }

  // Get classification based on percentage
  static String getClassification(double percentage) {
    if (percentage >= 90) return 'First Class with Distinction';
    if (percentage >= 75) return 'First Class';
    if (percentage >= 60) return 'Second Class';
    if (percentage >= 50) return 'Pass Class';
    return 'Fail';
  }

  // Get grade from percentage (10-point scale)
  static String getGrade10Point(double percentage) {
    if (percentage >= 90) return 'O';
    if (percentage >= 80) return 'A+';
    if (percentage >= 70) return 'A';
    if (percentage >= 60) return 'B+';
    if (percentage >= 50) return 'B';
    if (percentage >= 45) return 'C';
    if (percentage >= 40) return 'P';
    return 'F';
  }

  // Get grade from percentage (4-point scale)
  static String getGrade4Point(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Calculate required marks to achieve target percentage
  static double calculateRequiredMarks(
    double targetPercentage,
    double maxMarks, {
    double? currentMarks,
    double? currentTotal,
  }) {
    if (currentMarks != null && currentTotal != null) {
      // For remaining exams
      final remainingMarks = maxMarks - currentTotal;
      final targetMarks = (targetPercentage / 100) * maxMarks;
      return targetMarks - currentMarks;
    } else {
      // Simple calculation
      return (targetPercentage / 100) * maxMarks;
    }
  }

  // Get performance trend
  static String getPerformanceTrend(
    List<double> percentages, {
    int recentCount = 3,
  }) {
    if (percentages.length < 2) return 'Insufficient data';

    final recent = percentages.length <= recentCount
        ? percentages
        : percentages.sublist(percentages.length - recentCount);

    final avgRecent = recent.reduce((a, b) => a + b) / recent.length;
    final avgPrevious = percentages.length <= recentCount
        ? percentages.first
        : percentages.sublist(0, percentages.length - recentCount)
            .reduce((a, b) => a + b) /
        (percentages.length - recentCount);

    final difference = avgRecent - avgPrevious;

    if (difference >= 10) return 'Significantly Improved';
    if (difference >= 5) return 'Improved';
    if (difference > -5) return 'Stable';
    if (difference > -10) return 'Declined';
    return 'Significantly Declined';
  }

  // Available conversion formulas with descriptions
  static Map<String, Map<String, dynamic>> getFormulaDetails() {
    return {
      'default': {
        'name': 'Default Formula',
        'description': 'CGPA × 9.5',
        'multiplier': 9.5,
        'offset': 0.0,
      },
      'mumbai_university': {
        'name': 'Mumbai University',
        'description': '(CGPA × 7.1) + 11',
        'multiplier': 7.1,
        'offset': 11.0,
      },
      'anna_university': {
        'name': 'Anna University',
        'description': 'CGPA × 10',
        'multiplier': 10.0,
        'offset': 0.0,
      },
      'vtu': {
        'name': 'VTU',
        'description': '(CGPA - 0.75) × 10',
        'multiplier': 10.0,
        'offset': -7.5,
      },
      'gtu': {
        'name': 'GTU',
        'description': '(CGPA - 0.5) × 10',
        'multiplier': 10.0,
        'offset': -5.0,
      },
      'custom': {
        'name': 'Custom Formula',
        'description': 'Configurable',
        'multiplier': 9.5,
        'offset': 0.0,
      },
    };
  }
}
