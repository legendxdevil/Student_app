import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/percentage_service.dart';
import 'package:student_app/core/services/cgpa_service.dart';

class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends State<PercentageCalculatorScreen> {
  int _selectedTab = 0; // 0: CGPA to %, 1: Marks to %
  
  // CGPA to Percentage
  final _cgpaController = TextEditingController();
  String _selectedFormula = 'default';
  double _convertedPercentage = 0.0;

  // Marks to Percentage
  final List<Map<String, dynamic>> _subjects = [];
  double _overallPercentage = 0.0;
  bool _weightedCalculation = false;

  final List<Map<String, String>> _formulas = [
    {'value': 'default', 'label': 'Default (CGPA × 9.5)'},
    {'value': 'mumbai_university', 'label': 'Mumbai University'},
    {'value': 'anna_university', 'label': 'Anna University'},
    {'value': 'vtu', 'label': 'VTU'},
    {'value': 'gtu', 'label': 'GTU'},
  ];

  @override
  void initState() {
    super.initState();
    _addSubject();
  }

  void _addSubject() {
    setState(() {
      _subjects.add({
        'name': TextEditingController(),
        'marks': TextEditingController(),
        'maxMarks': TextEditingController(text: '100'),
        'credits': TextEditingController(text: '3'),
      });
    });
    _calculateOverallPercentage();
  }

  void _removeSubject(int index) {
    if (_subjects.length > 1) {
      setState(() {
        _subjects.removeAt(index);
      });
      _calculateOverallPercentage();
    }
  }

  void _convertCGPAToPercentage() {
    final cgpa = double.tryParse(_cgpaController.text) ?? 0;
    setState(() {
      _convertedPercentage = PercentageService.cgpaToPercentage(cgpa, formula: _selectedFormula);
    });
  }

  void _calculateOverallPercentage() {
    final subjects = _subjects.map((s) {
      return {
        'marks': double.tryParse(s['marks'].text) ?? 0,
        'maxMarks': double.tryParse(s['maxMarks'].text) ?? 100,
        'credits': double.tryParse(s['credits'].text) ?? 1,
      };
    }).toList();

    setState(() {
      _overallPercentage = PercentageService.calculateOverallPercentage(
        subjects,
        weightedByCredits: _weightedCalculation,
      );
    });
  }

  void _showFormulaDetails() {
    final details = PercentageService.getFormulaDetails()[_selectedFormula];
    if (details != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(details['name'] as String),
          content: Text('Formula: ${details['description']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _cgpaController.dispose();
    for (var subject in _subjects) {
      subject['name'].dispose();
      subject['marks'].dispose();
      subject['maxMarks'].dispose();
      subject['credits'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Percentage Calculator'),
      ),
      body: Column(
        children: [
          // Tab Selection
          Padding(
            padding: const EdgeInsets.all(20),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('CGPA to %')),
                ButtonSegment(value: 1, label: Text('Marks to %')),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (value) {
                setState(() => _selectedTab = value.first);
              },
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: _selectedTab == 0
                ? _buildCGPAToPercentageTab(theme)
                : _buildMarksToPercentageTab(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCGPAToPercentageTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Result Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Converted Percentage',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_convertedPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  PercentageService.getClassification(_convertedPercentage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CGPA Input
          TextField(
            controller: _cgpaController,
            decoration: const InputDecoration(
              labelText: 'Enter CGPA',
              prefixIcon: Icon(Icons.school_outlined),
              hintText: 'e.g., 8.5',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _convertCGPAToPercentage(),
          ),
          const SizedBox(height: 20),

          // Formula Selection
          DropdownButtonFormField<String>(
            value: _selectedFormula,
            decoration: InputDecoration(
              labelText: 'Conversion Formula',
              prefixIcon: const Icon(Icons.functions),
              suffixIcon: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showFormulaDetails,
              ),
            ),
            items: _formulas.map((formula) {
              return DropdownMenuItem(
                value: formula['value'],
                child: Text(formula['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedFormula = value!);
              _convertCGPAToPercentage();
            },
          ),
          const SizedBox(height: 24),

          // Formula Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Formulas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._formulas.map((formula) {
                    final isSelected = formula['value'] == _selectedFormula;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formula['label']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Reverse Calculation Card
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reverse Calculation',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CGPA from ${_convertedPercentage.toStringAsFixed(2)}% = ${PercentageService.percentageToCGPA(_convertedPercentage, formula: _selectedFormula).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksToPercentageTab(ThemeData theme) {
    return Column(
      children: [
        // Overall Percentage Card
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.successColor, AppTheme.accentColor],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Overall Percentage',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Weighted by credits',
                    child: Switch(
                      value: _weightedCalculation,
                      onChanged: (value) {
                        setState(() => _weightedCalculation = value);
                        _calculateOverallPercentage();
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${_overallPercentage.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                PercentageService.getClassification(_overallPercentage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Subjects List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              return _buildMarksSubjectCard(index);
            },
          ),
        ),

        // Add Subject Button
        Container(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarksSubjectCard(int index) {
    final subject = _subjects[index];

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
                  child: TextField(
                    controller: subject['marks'],
                    decoration: const InputDecoration(
                      labelText: 'Marks Obtained',
                      prefixIcon: Icon(Icons.score),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _calculateOverallPercentage(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: subject['maxMarks'],
                    decoration: const InputDecoration(
                      labelText: 'Max Marks',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateOverallPercentage(),
                  ),
                ),
              ],
            ),
            if (_weightedCalculation) ...[
              const SizedBox(height: 12),
              TextField(
                controller: subject['credits'],
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  prefixIcon: Icon(Icons.timelapse),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateOverallPercentage(),
              ),
            ],
            const SizedBox(height: 8),
            // Individual percentage display
            Builder(
              builder: (context) {
                final marks = double.tryParse(subject['marks'].text) ?? 0;
                final maxMarks = double.tryParse(subject['maxMarks'].text) ?? 100;
                final percentage = PercentageService.calculatePercentage(marks, maxMarks);
                return Text(
                  'Individual: ${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
