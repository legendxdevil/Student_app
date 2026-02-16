import 'package:flutter/material.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/data/models/semester_model.dart';
import 'package:student_app/data/models/subject_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _apiKey;
  bool _showApiKeyInput = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _addWelcomeMessage();
  }

  Future<void> _loadApiKey() async {
    _apiKey = StorageService.instance.getString('ai_api_key');
    setState(() {
      _showApiKeyInput = _apiKey == null || _apiKey!.isEmpty;
    });
  }

  void _addWelcomeMessage() {
    _messages.add({
      'type': 'ai',
      'text': 'Hello! I\'m your AI Academic Assistant. I can help you analyze your academic performance, provide study suggestions, and offer motivation. How can I assist you today?',
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'type': 'user',
        'text': text,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Get academic context
    final context = await _getAcademicContext();
    
    // Generate response
    final response = await _generateAIResponse(text, context);

    setState(() {
      _messages.add({
        'type': 'ai',
        'text': response,
        'timestamp': DateTime.now(),
      });
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<String> _getAcademicContext() async {
    final semesters = await DatabaseService.instance.getAllSemesters();
    final allSubjects = await DatabaseService.instance.getAllSubjects();
    
    if (semesters.isEmpty) return 'No academic data available.';

    double totalCGPA = 0;
    double totalCredits = 0;
    int completedSemesters = 0;

    for (var semester in semesters) {
      if (semester.sgpa != null && semester.totalCredits != null) {
        totalCGPA += semester.sgpa! * semester.totalCredits!;
        totalCredits += semester.totalCredits!;
        completedSemesters++;
      }
    }

    final cgpa = totalCredits > 0 ? totalCGPA / totalCredits : 0;
    
    return '''
Student Context:
- Overall CGPA: ${cgpa.toStringAsFixed(2)}
- Total Semesters: ${semesters.length}
- Completed Semesters: $completedSemesters
- Total Subjects: ${allSubjects.length}
- Academic System: CGPA-based
'''.trim();
  }

  Future<String> _generateAIResponse(String userMessage, String academicContext) async {
    // Check for specific queries
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('cgpa') || lowerMessage.contains('gpa')) {
      return _analyzeCGPA(academicContext);
    }
    if (lowerMessage.contains('improve') || lowerMessage.contains('better')) {
      return _provideImprovementTips(academicContext);
    }
    if (lowerMessage.contains('study') || lowerMessage.contains('exam')) {
      return _provideStudyTips();
    }
    if (lowerMessage.contains('motivation') || lowerMessage.contains('stress')) {
      return _provideMotivation();
    }
    if (lowerMessage.contains('trend') || lowerMessage.contains('performance')) {
      return _analyzeTrends(academicContext);
    }

    // Default response with academic context
    return '''Based on your academic data:

$academicContext

$userMessage

To get specific insights, you can ask me about:
- Your CGPA analysis
- Study improvement tips
- Exam preparation strategies
- Performance trends
- Motivation and stress management'''.trim();
  }

  String _analyzeCGPA(String context) {
    final cgpaMatch = RegExp(r'Overall CGPA: ([\d.]+)').firstMatch(context);
    final cgpa = cgpaMatch != null ? double.tryParse(cgpaMatch.group(1)!) : null;

    if (cgpa == null) {
      return 'I don\'t see any CGPA data yet. Start by adding your semester results in the CGPA Calculator section to get personalized analysis!';
    }

    String analysis = 'Your CGPA is ${cgpa.toStringAsFixed(2)}. ';
    
    if (cgpa >= 9) {
      analysis += 'This is outstanding! You\'re in the top tier of academic performance. Keep up the excellent work!';
    } else if (cgpa >= 8) {
      analysis += 'This is excellent performance! You\'re doing great. Focus on maintaining this standard and pushing for even higher scores.';
    } else if (cgpa >= 7) {
      analysis += 'This is very good performance! You\'re above average. With some focused effort, you can reach the excellent tier.';
    } else if (cgpa >= 6) {
      analysis += 'This is good performance, but there\'s room for improvement. Identify your weak subjects and work on them strategically.';
    } else {
      analysis += 'There\'s significant room for improvement. Don\'t worry - with the right study strategy and dedication, you can improve your scores substantially.';
    }

    return analysis;
  }

  String _provideImprovementTips(String context) {
    return '''Here are personalized tips to improve your academic performance:

1. **Subject Analysis**: Review your lowest-scoring subjects and allocate more study time to them.

2. **Consistent Study Schedule**: Create a daily study routine. Consistency beats cramming every time.

3. **Active Learning**: Don't just read - practice problems, teach concepts to others, and use flashcards.

4. **Past Papers**: Solve previous year question papers to understand exam patterns.

5. **Time Management**: Use techniques like Pomodoro (25 min study, 5 min break) for better focus.

6. **Group Study**: Discuss difficult topics with classmates - explaining concepts reinforces learning.

7. **Seek Help**: Don't hesitate to ask professors or peers when you're stuck on a concept.

8. **Health Matters**: Sleep well, exercise regularly, and maintain a balanced diet for optimal brain function.

Would you like specific tips for any particular subject or exam?'''.trim();
  }

  String _provideStudyTips() {
    return '''Effective Study Strategies:

**Before the Exam:**
- Start early - don't procrastinate
- Create a study timetable
- Gather all materials (notes, textbooks, past papers)
- Identify weak areas and focus on them

**During Study Sessions:**
- Use active recall (test yourself instead of re-reading)
- Practice spaced repetition
- Take regular breaks to avoid burnout
- Stay hydrated and maintain good posture

**Exam Day:**
- Get adequate sleep the night before
- Eat a healthy breakfast
- Arrive early to stay calm
- Read questions carefully before answering
- Manage your time wisely

**Memory Techniques:**
- Mnemonics for memorization
- Mind maps for visual learners
- Teaching others to reinforce concepts
- Connecting new knowledge to what you already know

Good luck with your preparation!'''.trim();
  }

  String _provideMotivation() {
    final quotes = [
      'Success is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill',
      'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
      'Don\'t watch the clock; do what it does. Keep going. - Sam Levenson',
      'Education is the passport to the future. - Malcolm X',
      'Your time is limited, don\'t waste it living someone else\'s life. - Steve Jobs',
    ];

    return '''${quotes[DateTime.now().millisecond % quotes.length]}

Remember:
- Every expert was once a beginner
- Progress, not perfection
- Your current situation is not your final destination
- Small steps every day lead to big results
- Believe in yourself and your abilities

You've got this! Keep pushing forward, and the results will follow. 💪'''.trim();
  }

  String _analyzeTrends(String context) {
    return '''To analyze your performance trends, I need more semester data. 

Based on your current data:
$context

**What to track:**
1. Compare SGPA across semesters
2. Identify subjects with consistent performance
3. Note any upward or downward trends
4. Correlate study habits with results

**Improvement Indicators:**
- Increasing SGPA trend
- Better grades in challenging subjects
- Consistent attendance
- Reduced backlog subjects

Add more semester data in the Academic History section for detailed trend analysis!'''.trim();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveApiKey(String key) async {
    await StorageService.instance.setString('ai_api_key', key);
    setState(() {
      _apiKey = key;
      _showApiKeyInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() => _showApiKeyInput = !_showApiKeyInput);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // API Key Input (if needed)
          if (_showApiKeyInput)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Key Settings',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter OpenAI API Key (Optional)',
                      hintText: 'sk-...',
                      helperText: 'Leave empty to use built-in assistant',
                    ),
                    obscureText: true,
                    onSubmitted: _saveApiKey,
                  ),
                ],
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['type'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppTheme.primaryColor
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : null,
                        bottomLeft: !isUser ? const Radius.circular(4) : null,
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
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
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your academics...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
