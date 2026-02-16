import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/bloc/theme_bloc.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/data/models/semester_model.dart';
import 'package:student_app/data/models/subject_model.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedFormula = 'default';
  String _gradeScale = '10_point';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _selectedFormula = StorageService.instance.getString('percentage_formula') ?? 'default';
      _gradeScale = StorageService.instance.getString('grade_scale') ?? '10_point';
      _notificationsEnabled = StorageService.instance.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _exportData() async {
    try {
      final semesters = await DatabaseService.instance.getAllSemesters();
      final subjects = await DatabaseService.instance.getAllSubjects();

      // Create CSV data
      List<List<dynamic>> csvData = [
        ['Student Academic Data Export'],
        ['Generated on ${DateTime.now().toIso8601String()}'],
        [],
        ['Semesters'],
        ['ID', 'Name', 'Number', 'SGPA', 'Total Credits', 'Completed', 'Start Date', 'End Date'],
        ...semesters.map((s) => [
          s.id,
          s.semesterName,
          s.semesterNumber,
          s.sgpa,
          s.totalCredits,
          s.isCompleted ? 'Yes' : 'No',
          s.startDate?.toIso8601String() ?? '',
          s.endDate?.toIso8601String() ?? '',
        ]),
        [],
        ['Subjects'],
        ['ID', 'Semester ID', 'Name', 'Code', 'Credits', 'Marks', 'Max Marks', 'Grade', 'Grade Points'],
        ...subjects.map((s) {
          final subject = s as SubjectModel;
          return [
            subject.id ?? 0,
            subject.semesterId,
            subject.name,
            subject.code ?? '',
            subject.credits,
            subject.marksObtained,
            subject.maxMarks,
            subject.grade ?? '',
            subject.gradePoints,
          ];
        }),
      ];

      final csv = const ListToCsvConverter().convert(csvData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/student_data_export.csv');
      await file.writeAsString(csv);

      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'My Academic Data Export',
      );

      _showSnackBar('Data exported successfully!');
    } catch (e) {
      _showSnackBar('Export failed: $e');
    }
  }

  Future<void> _importData() async {
    // Disabled in this build because the file_picker plugin is not
    // compatible with the current Android embedding. Export still works.
    _showSnackBar('Import from CSV is not available in this APK build.');
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your academic records. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.close();
      await StorageService.instance.clear();
      _showSnackBar('All data cleared. Restart the app.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance Section
          _buildSectionHeader(theme, 'Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Academic Settings
          _buildSectionHeader(theme, 'Academic Settings'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.functions, color: AppTheme.accentColor),
                  title: const Text('Percentage Formula'),
                  subtitle: Text(_getFormulaLabel(_selectedFormula)),
                  onTap: () => _showFormulaSelectionDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.grade, color: AppTheme.successColor),
                  title: const Text('Grade Scale'),
                  subtitle: Text(_gradeScale == '10_point' ? '10 Point Scale' : '4 Point Scale'),
                  onTap: () => _showGradeScaleSelectionDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader(theme, 'Data Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: AppTheme.primaryColor),
                  title: const Text('Export Data'),
                  subtitle: const Text('Save your academic records as CSV'),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload, color: AppTheme.accentColor),
                  title: const Text('Import Data'),
                  subtitle: const Text('Restore from CSV backup'),
                  onTap: _importData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently delete everything'),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications
          _buildSectionHeader(theme, 'Notifications'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: AppTheme.warningColor),
              title: const Text('Push Notifications'),
              subtitle: const Text('Reminders for exams and goals'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  await StorageService.instance.setBool('notifications_enabled', value);
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // AI Settings
          _buildSectionHeader(theme, 'AI Assistant'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.psychology, color: AppTheme.secondaryColor),
              title: const Text('API Key'),
              subtitle: const Text('Configure AI service key'),
              onTap: () => _showApiKeyDialog(),
            ),
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader(theme, 'About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info, color: AppTheme.primaryColor),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: AppTheme.accentColor),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help, color: AppTheme.successColor),
                  title: const Text('Help & Support'),
                  onTap: () {
                    // Show help
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getFormulaLabel(String formula) {
    final formulas = {
      'default': 'Default (CGPA × 9.5)',
      'mumbai_university': 'Mumbai University',
      'anna_university': 'Anna University',
      'vtu': 'VTU',
      'gtu': 'GTU',
    };
    return formulas[formula] ?? 'Default';
  }

  void _showFormulaSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Percentage Formula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'default',
            'mumbai_university',
            'anna_university',
            'vtu',
            'gtu',
          ].map((formula) {
            return RadioListTile<String>(
              title: Text(_getFormulaLabel(formula)),
              value: formula,
              groupValue: _selectedFormula,
              onChanged: (value) async {
                await StorageService.instance.setString('percentage_formula', value!);
                setState(() => _selectedFormula = value);
                if (mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGradeScaleSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Grade Scale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('10 Point Scale (O, A+, A, B+, B...)'),
              value: '10_point',
              groupValue: _gradeScale,
              onChanged: (value) async {
                await StorageService.instance.setString('grade_scale', value!);
                setState(() => _gradeScale = value);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('4 Point Scale (A, B, C, D...)'),
              value: '4_point',
              groupValue: _gradeScale,
              onChanged: (value) async {
                await StorageService.instance.setString('grade_scale', value!);
                setState(() => _gradeScale = value);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(
      text: StorageService.instance.getString('ai_api_key') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'OpenAI API Key',
            hintText: 'sk-...',
            helperText: 'Leave empty to use built-in assistant',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.instance.setString('ai_api_key', controller.text);
              _showSnackBar('API key saved');
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
