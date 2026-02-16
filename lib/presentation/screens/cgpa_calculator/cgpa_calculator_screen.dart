import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/cgpa_service.dart';
import 'package:student_app/data/models/semester_model.dart';
import 'package:student_app/data/models/subject_model.dart';
import 'package:student_app/core/services/database_service.dart';

class CGPACalculatorScreen extends StatefulWidget {
  const CGPACalculatorScreen({super.key});

  @override
  State<CGPACalculatorScreen> createState() => _CGPACalculatorScreenState();
}

class _CGPACalculatorScreenState extends State<CGPACalculatorScreen> {
  final List<Map<String, dynamic>> _subjects = [];
  double _sgpa = 0.0;
  String _gradeScale = '10_point';
  int? _selectedSemesterId;
  List<SemesterModel> _semesters = [];

  final List<String> _grades10Point = ['O', 'A+', 'A', 'B+', 'B', 'C', 'P', 'F'];
  final List<String> _grades4Point = ['A', 'B', 'C', 'D', 'F'];

  @override
  void initState() {
    super.initState();
    _loadSemesters();
    _addSubject(); // Add first subject by default
  }

  Future<void> _loadSemesters() async {
    final semesters = await DatabaseService.instance.getAllSemesters();
    setState(() {
      _semesters = semesters;
    });
  }

  void _addSubject() {
    setState(() {
      _subjects.add({
        'name': TextEditingController(),
        'credits': TextEditingController(text: '3'),
        'marks': TextEditingController(),
        'grade': _gradeScale == '10_point' ? 'A' : 'B',
      });
    });
    _calculateSGPA();
  }

  void _removeSubject(int index) {
    if (_subjects.length > 1) {
      setState(() {
        _subjects.removeAt(index);
      });
      _calculateSGPA();
    }
  }

  void _calculateSGPA() {
    double totalGradePoints = 0;
    double totalCredits = 0;

    for (var subject in _subjects) {
      final credits = double.tryParse(subject['credits'].text) ?? 0;
      final marks = double.tryParse(subject['marks'].text) ?? 0;
      final maxMarks = 100.0;

      double gradePoints;
      if (_gradeScale == '10_point') {
        gradePoints = CGPAService.marksToGradePoints10(marks, maxMarks);
      } else {
        gradePoints = CGPAService.marksToGradePoints4(marks, maxMarks);
      }

      totalGradePoints += gradePoints * credits;
      totalCredits += credits;
    }

    setState(() {
      _sgpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
    });
  }

  Future<void> _saveToSemester() async {
    if (_selectedSemesterId == null) {
      _showSnackBar('Please select a semester');
      return;
    }

    // Save subjects to database
    for (var subjectData in _subjects) {
      final marks = double.tryParse(subjectData['marks'].text) ?? 0;
      final credits = double.tryParse(subjectData['credits'].text) ?? 0;
      
      double gradePoints;
      String grade;
      if (_gradeScale == '10_point') {
        gradePoints = CGPAService.marksToGradePoints10(marks, 100);
        grade = CGPAService.marksToGrade10(marks, 100);
      } else {
        gradePoints = CGPAService.marksToGradePoints4(marks, 100);
        grade = CGPAService.marksToGrade4(marks, 100);
      }

      final subject = SubjectModel(
        semesterId: _selectedSemesterId!,
        name: subjectData['name'].text,
        credits: credits,
        marksObtained: marks,
        maxMarks: 100,
        grade: grade,
        gradePoints: gradePoints,
      );

      await DatabaseService.instance.insertSubject(subject);
    }

    // Update semester with SGPA
    final semester = await DatabaseService.instance.getSemester(_selectedSemesterId!);
    if (semester != null) {
      final totalCredits = _subjects.fold<double>(
        0,
        (sum, s) => sum + (double.tryParse(s['credits'].text) ?? 0),
      );
      
      await DatabaseService.instance.updateSemester(
        semester.copyWith(
          sgpa: _sgpa,
          totalCredits: totalCredits,
          completedCredits: totalCredits,
          isCompleted: true,
        ),
      );
    }

    _showSnackBar('Results saved successfully!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddSemesterDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Semester'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Semester Name (e.g., Semester 1)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Semester Number',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final semester = SemesterModel(
                semesterNumber: int.tryParse(numberController.text) ?? 1,
                semesterName: nameController.text,
              );
              await DatabaseService.instance.insertSemester(semester);
              await _loadSemesters();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Calculator'),
      ),
      body: Column(
        children: [
          // SGPA Result Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Calculated SGPA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _sgpa.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CGPAService.getPerformanceClassification(_sgpa, _gradeScale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Grade Scale Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '10_point', label: Text('10 Point')),
                ButtonSegment(value: '4_point', label: Text('4 Point')),
              ],
              selected: {_gradeScale},
              onSelectionChanged: (value) {
                setState(() {
                  _gradeScale = value.first;
                  _calculateSGPA();
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Semester Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedSemesterId,
                    decoration: const InputDecoration(
                      labelText: 'Save to Semester',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Select Semester'),
                      ),
                      ..._semesters.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.semesterName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSemesterId = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAddSemesterDialog,
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  tooltip: 'Add Semester',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subjects List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                return _buildSubjectCard(index);
              },
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addSubject,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveToSemester,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Results'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(int index) {
    final subject = _subjects[index];
    final grades = _gradeScale == '10_point' ? _grades10Point : _grades4Point;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subject['name'],
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    onChanged: (_) => _calculateSGPA(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeSubject(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: subject['marks'],
                    decoration: const InputDecoration(
                      labelText: 'Marks (0-100)',
                      prefixIcon: Icon(Icons.score),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => _calculateSGPA(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: subject['credits'],
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateSGPA(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: subject['grade'],
              decoration: const InputDecoration(
                labelText: 'Grade',
                prefixIcon: Icon(Icons.grade),
              ),
              items: grades.map((grade) {
                final points = _gradeScale == '10_point'
                    ? CGPAService.gradeScale10Point[grade]
                    : CGPAService.gradeScale4Point[grade];
                return DropdownMenuItem(
                  value: grade,
                  child: Text('$grade (${points?.toStringAsFixed(0)} pts)'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  subject['grade'] = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
