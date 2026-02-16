import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/core/services/cgpa_service.dart';
import 'package:student_app/data/models/semester_model.dart';
import 'package:student_app/data/models/subject_model.dart';

class AcademicHistoryScreen extends StatefulWidget {
  const AcademicHistoryScreen({super.key});

  @override
  State<AcademicHistoryScreen> createState() => _AcademicHistoryScreenState();
}

class _AcademicHistoryScreenState extends State<AcademicHistoryScreen> {
  List<SemesterModel> _semesters = [];
  Map<int, List<SubjectModel>> _semesterSubjects = {};
  bool _isLoading = true;
  double _overallCGPA = 0.0;
  double _highestSGPA = 0.0;
  double _lowestSGPA = double.infinity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final semesters = await DatabaseService.instance.getAllSemesters();
    
    Map<int, List<SubjectModel>> subjectsMap = {};
    double totalCGPA = 0;
    double totalCredits = 0;
    double highest = 0;
    double lowest = double.infinity;

    for (var semester in semesters) {
      final subjects = await DatabaseService.instance.getSubjectsBySemester(semester.id!);
      subjectsMap[semester.id!] = subjects;

      if (semester.sgpa != null && semester.totalCredits != null) {
        totalCGPA += semester.sgpa! * semester.totalCredits!;
        totalCredits += semester.totalCredits!;
        
        if (semester.sgpa! > highest) highest = semester.sgpa!;
        if (semester.sgpa! < lowest) lowest = semester.sgpa!;
      }
    }

    setState(() {
      _semesters = semesters;
      _semesterSubjects = subjectsMap;
      _overallCGPA = totalCredits > 0 ? totalCGPA / totalCredits : 0.0;
      _highestSGPA = highest;
      _lowestSGPA = lowest == double.infinity ? 0.0 : lowest;
      _isLoading = false;
    });
  }

  Future<void> _deleteSemester(int semesterId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester'),
        content: const Text('Are you sure you want to delete this semester and all its subjects?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteSemester(semesterId);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(theme),
                    const SizedBox(height: 24),

                    // Performance Chart
                    if (_semesters.isNotEmpty) ...[
                      Text(
                        'Performance Trend',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceChart(),
                      const SizedBox(height: 24),
                    ],

                    // Semesters List
                    Text(
                      'Semester Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _semesters.isEmpty
                        ? _buildEmptyState(theme)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _semesters.length,
                            itemBuilder: (context, index) {
                              return _buildSemesterCard(_semesters[index], theme);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Academic History Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding semesters to track your academic progress',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            title: 'Overall CGPA',
            value: _overallCGPA.toStringAsFixed(2),
            icon: Icons.grade,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            title: 'Best SGPA',
            value: _highestSGPA.toStringAsFixed(2),
            icon: Icons.trending_up,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            title: 'Semesters',
            value: '${_semesters.length}',
            icon: Icons.calendar_today,
            color: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final spots = _semesters.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.sgpa ?? 0,
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < _semesters.length) {
                    return Text(
                      'S${value.toInt() + 1}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: 10,
        ),
      ),
    );
  }

  Widget _buildSemesterCard(SemesterModel semester, ThemeData theme) {
    final subjects = _semesterSubjects[semester.id] ?? [];
    final isExpanded = ValueNotifier<bool>(false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${semester.semesterNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              semester.semesterName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${subjects.length} subjects • ${semester.totalCredits?.toStringAsFixed(0) ?? '0'} credits',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (semester.sgpa != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSGPAColor(semester.sgpa!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SGPA: ${semester.sgpa!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getSGPAColor(semester.sgpa!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteSemester(semester.id!),
                ),
              ],
            ),
          ),
          if (subjects.isNotEmpty)
            ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, child) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () => isExpanded.value = !expanded,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              expanded ? 'Hide Subjects' : 'View Subjects',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              expanded ? Icons.expand_less : Icons.expand_more,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expanded)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: subjects.map((subject) {
                            return _buildSubjectRow(subject, theme);
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(SubjectModel subject, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subject.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${subject.credits.toStringAsFixed(0)} cr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              subject.grade ?? '-',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getGradeColor(subject.grade),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              subject.gradePoints?.toStringAsFixed(2) ?? '-',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSGPAColor(double sgpa) {
    if (sgpa >= 9) return AppTheme.successColor;
    if (sgpa >= 7) return AppTheme.accentColor;
    if (sgpa >= 5) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) return Colors.grey;
    if (grade == 'O' || grade == 'A+' || grade == 'A') return AppTheme.successColor;
    if (grade == 'B+' || grade == 'B' || grade == 'C') return AppTheme.accentColor;
    if (grade == 'P' || grade == 'D') return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
