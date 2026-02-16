import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:student_app/app.dart';
import 'package:student_app/core/services/database_service.dart';
import 'package:student_app/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  await StorageService.instance.init();
  // sqflite is not supported on web. Skip DB init on web to avoid runtime crashes.
  if (!kIsWeb) {
    await DatabaseService.instance.init();
  }
  
  runApp(const StudentApp());
}
