import 'package:flutter/material.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/data/models/student_model.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _institutionController = TextEditingController();
  
  String _academicSystem = 'cgpa';
  String _gradeScale = '10_point';
  bool _isEditing = false;
  bool _isLoading = true;
  StudentModel? _student;

  final List<Map<String, String>> _academicSystems = [
    {'value': 'cgpa', 'label': 'CGPA System'},
    {'value': 'percentage', 'label': 'Percentage System'},
    {'value': 'grade', 'label': 'Grade-based System'},
  ];

  final List<Map<String, String>> _gradeScales = [
    {'value': '10_point', 'label': '10 Point Scale'},
    {'value': '4_point', 'label': '4 Point Scale'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final student = await DatabaseService.instance.getStudentProfile();
    if (student != null) {
      _nameController.text = student.name;
      _courseController.text = student.course ?? '';
      _institutionController.text = student.institution ?? '';
      _academicSystem = student.academicSystem;
      _gradeScale = student.gradeScale ?? '10_point';
      _student = student;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final student = StudentModel(
      id: _student?.id,
      name: _nameController.text.trim(),
      course: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
      institution: _institutionController.text.trim().isEmpty ? null : _institutionController.text.trim(),
      academicSystem: _academicSystem,
      gradeScale: _gradeScale,
    );

    if (_student?.id != null) {
      await DatabaseService.instance.updateStudentProfile(student);
    } else {
      await DatabaseService.instance.saveStudentProfile(student);
    }

    setState(() {
      _isEditing = false;
      _student = student;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _student?.name ?? 'New Student',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_student?.course != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _student!.course!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    _buildSectionTitle(theme, 'Personal Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _courseController,
                      label: 'Course / Stream',
                      icon: Icons.school_outlined,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _institutionController,
                      label: 'College / School',
                      icon: Icons.business_outlined,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),

                    // Academic System
                    _buildSectionTitle(theme, 'Academic System'),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _academicSystem,
                      items: _academicSystems,
                      label: 'Grading System',
                      enabled: _isEditing,
                      onChanged: (value) {
                        setState(() => _academicSystem = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_academicSystem == 'cgpa')
                      _buildDropdown(
                        value: _gradeScale,
                        items: _gradeScales,
                        label: 'Grade Scale',
                        enabled: _isEditing,
                        onChanged: (value) {
                          setState(() => _gradeScale = value!);
                        },
                      ),
                    const SizedBox(height: 32),

                    // Save Button (when editing)
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Profile'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<Map<String, String>> items,
    required String label,
    required bool enabled,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.settings_outlined),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
