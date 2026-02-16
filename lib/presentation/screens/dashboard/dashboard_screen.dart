import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/data/models/student_model.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/data/models/subject_model.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StudentModel? _student;
  bool _isLoading = true;
  double _cgpa = 0.0;
  int _totalSemesters = 0;
  int _totalSubjects = 0;

  // For pie chart
  double _highCount = 0; // >= 75%
  double _mediumCount = 0; // 60-74%
  double _lowCount = 0; // 40-59%
  double _atRiskCount = 0; // < 40%

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildPerformanceSection(ThemeData theme) {
    final total = _highCount + _mediumCount + _lowCount + _atRiskCount;

    if (total == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject performance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add marks for your subjects to see a performance breakdown.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject performance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Visual overview of how you are doing across subjects.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: [
                      if (_highCount > 0)
                        PieChartSectionData(
                          color: const Color(0xFF34D399),
                          value: _highCount,
                          title: '',
                          radius: 40,
                        ),
                      if (_mediumCount > 0)
                        PieChartSectionData(
                          color: const Color(0xFF60A5FA),
                          value: _mediumCount,
                          title: '',
                          radius: 40,
                        ),
                      if (_lowCount > 0)
                        PieChartSectionData(
                          color: const Color(0xFFFBBF24),
                          value: _lowCount,
                          title: '',
                          radius: 40,
                        ),
                      if (_atRiskCount > 0)
                        PieChartSectionData(
                          color: const Color(0xFFFB7185),
                          value: _atRiskCount,
                          title: '',
                          radius: 40,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFF34D399),
                      label: 'High (≥ 75%)',
                      value: _highCount,
                      total: total,
                    ),
                    _buildLegendItem(
                      color: const Color(0xFF60A5FA),
                      label: 'Medium (60–74%)',
                      value: _mediumCount,
                      total: total,
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFBBF24),
                      label: 'Low (40–59%)',
                      value: _lowCount,
                      total: total,
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFB7185),
                      label: 'At risk (< 40%)',
                      value: _atRiskCount,
                      total: total,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double value,
    required double total,
  }) {
    if (value == 0) return const SizedBox.shrink();

    final percentage = (value / total) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text('${percentage.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    final student = await DatabaseService.instance.getStudentProfile();
    final semesters = await DatabaseService.instance.getAllSemesters();
    final subjects = await DatabaseService.instance.getAllSubjects();

    // Calculate overall CGPA
    double totalCGPA = 0;
    double totalCredits = 0;
    for (var semester in semesters) {
      if (semester.sgpa != null && semester.totalCredits != null) {
        totalCGPA += semester.sgpa! * semester.totalCredits!;
        totalCredits += semester.totalCredits!;
      }
    }

    // Calculate subject performance buckets for pie chart
    double high = 0;
    double medium = 0;
    double low = 0;
    double atRisk = 0;

    for (SubjectModel s in subjects) {
      final percent = s.percentage;
      if (percent == null) continue;

      if (percent >= 75) {
        high++;
      } else if (percent >= 60) {
        medium++;
      } else if (percent >= 40) {
        low++;
      } else {
        atRisk++;
      }
    }

    setState(() {
      _student = student;
      _cgpa = totalCredits > 0 ? totalCGPA / totalCredits : 0.0;
      _totalSemesters = semesters.length;
      _totalSubjects = subjects.length;
      _highCount = high;
      _mediumCount = medium;
      _lowCount = low;
      _atRiskCount = atRisk;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
                    // Welcome Section
                    _buildWelcomeSection(theme),
                    const SizedBox(height: 24),
                    
                    // CGPA Overview Card
                    _buildCGPACard(theme),
                    const SizedBox(height: 20),

                    // Performance Pie Chart
                    _buildPerformanceSection(theme),
                    const SizedBox(height: 24),

                    // Quick Stats
                    _buildQuickStats(theme),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${_student?.name ?? 'Student'}!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your academic journey',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCGPACard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF5EDE2)
            : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall CGPA',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cgpa.toStringAsFixed(2),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getPerformanceText(_cgpa),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceText(double cgpa) {
    if (cgpa >= 9) return 'Outstanding Performance';
    if (cgpa >= 8) return 'Excellent Performance';
    if (cgpa >= 7) return 'Very Good Performance';
    if (cgpa >= 6) return 'Good Performance';
    if (cgpa >= 5) return 'Average Performance';
    return 'Keep Working Hard';
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.school_outlined,
            value: '$_totalSemesters',
            label: 'Semesters',
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.book_outlined,
            value: '$_totalSubjects',
            label: 'Subjects',
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.emoji_events_outlined,
            value: '${(_cgpa * 10).toStringAsFixed(0)}%',
            label: 'Percentage',
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                theme,
                icon: Icons.calculate,
                label: 'CGPA Calc',
                onTap: () => context.go('/cgpa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                theme,
                icon: Icons.percent,
                label: 'Percentage',
                onTap: () => context.go('/percentage'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                theme,
                icon: Icons.history,
                label: 'History',
                onTap: () => context.go('/history'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                theme,
                icon: Icons.psychology,
                label: 'AI Help',
                onTap: () => context.go('/ai-assistant'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
