import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/data/models/student_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Profile setup controllers
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _institutionController = TextEditingController();
  String _academicSystem = 'cgpa';
  String _gradeScale = '10_point';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _courseController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Save student profile
    final student = StudentModel(
      name: _nameController.text.trim().isEmpty ? 'Student' : _nameController.text.trim(),
      course: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
      institution: _institutionController.text.trim().isEmpty ? null : _institutionController.text.trim(),
      academicSystem: _academicSystem,
      gradeScale: _gradeScale,
    );

    await DatabaseService.instance.saveStudentProfile(student);
    await StorageService.instance.setBool('onboarding_completed', true);

    if (mounted) {
      context.go('/');
    }
  }

  void _skipOnboarding() async {
    await StorageService.instance.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(theme),
                  _buildFeaturesPage(theme),
                  _buildProfileSetupPage(theme),
                  _buildReadyPage(theme),
                ],
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.school,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to Student Hub',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your complete academic companion for tracking CGPA, calculating percentages, and achieving academic success.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(ThemeData theme) {
    final features = [
      {
        'icon': Icons.calculate,
        'title': 'CGPA Calculator',
        'description': 'Calculate semester and overall CGPA with credit-based system',
      },
      {
        'icon': Icons.percent,
        'title': 'Percentage Converter',
        'description': 'Convert CGPA to percentage with multiple university formulas',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Performance Tracking',
        'description': 'Visual charts and trends to monitor your academic progress',
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Assistant',
        'description': 'Get personalized study tips and academic insights',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Powerful Features',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need to excel academically',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildFeatureCard(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['description'] as String,
                  color: [AppTheme.primaryColor, AppTheme.accentColor, AppTheme.successColor, AppTheme.secondaryColor][index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Up Your Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize your academic tracking experience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(
              labelText: 'Course / Stream',
              hintText: 'e.g., Computer Science',
              prefixIcon: Icon(Icons.school),
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(
              labelText: 'College / University',
              hintText: 'e.g., MIT',
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Academic System',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'cgpa', label: Text('CGPA')),
              ButtonSegment(value: 'percentage', label: Text('%')),
              ButtonSegment(value: 'grade', label: Text('Grade')),
            ],
            selected: {_academicSystem},
            onSelectionChanged: (value) {
              setState(() => _academicSystem = value.first);
            },
          ),
          
          if (_academicSystem == 'cgpa') ...[
            const SizedBox(height: 24),
            Text(
              'Grade Scale',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '10_point', label: Text('10 Point')),
                ButtonSegment(value: '4_point', label: Text('4 Point')),
              ],
              selected: {_gradeScale},
              onSelectionChanged: (value) {
                setState(() => _gradeScale = value.first);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadyPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.successColor, AppTheme.accentColor],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'You\'re All Set!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your profile is ready. Start tracking your academic journey and achieve your goals!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildProfileInfoRow('Name', _nameController.text.isEmpty ? 'Student' : _nameController.text),
                const Divider(height: 16),
                _buildProfileInfoRow('System', _academicSystem.toUpperCase()),
                if (_academicSystem == 'cgpa') ...[
                  const Divider(height: 16),
                  _buildProfileInfoRow('Scale', _gradeScale == '10_point' ? '10 Point' : '4 Point'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
