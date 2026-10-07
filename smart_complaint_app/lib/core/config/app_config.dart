import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment.dart';

class AppConfig {
  static late final String apiBaseUrl;
  static late final String appName;
  static late final String appVersion;
  static late final AppEnvironment environment;
  
  // Feature Flags
  static late final bool enableAI;
  static late final bool enableAnalytics;
  static late final bool enableDebugLogs;

  static Future<void> initialize() async {
    // Determine active environment
    environment = Environment.current;

    // Load configurations from assets/.env
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e) {
      debugPrint('Warning: assets/.env file failed to load. Falling back to platform environment variables.');
    }

    // Retrieve and validate values (fail fast pattern)
    apiBaseUrl = dotenv.get('API_BASE_URL', fallback: '');
    appName = dotenv.get('APP_NAME', fallback: 'Smart Complaint Analyzer');
    appVersion = dotenv.get('APP_VERSION', fallback: '1.0.0');

    // Parse feature flags
    enableAI = dotenv.get('ENABLE_AI', fallback: 'false').toLowerCase() == 'true';
    enableAnalytics = dotenv.get('ENABLE_ANALYTICS', fallback: 'false').toLowerCase() == 'true';
    enableDebugLogs = dotenv.get('ENABLE_DEBUG_LOGS', fallback: 'false').toLowerCase() == 'true';

    _validate();
  }

  static void _validate() {
    if (apiBaseUrl.isEmpty) {
      throw Exception('FATAL: API_BASE_URL environment variable is required but is missing or empty.');
    }

    if (enableDebugLogs) {
      debugPrint('--- APP CONFIGURATION INITIALIZED ---');
      debugPrint('Environment: ${environment.name}');
      debugPrint('API Base URL: $apiBaseUrl');
      debugPrint('App Version: $appVersion');
      debugPrint('Feature Flags: [AI: $enableAI, Analytics: $enableAnalytics, DebugLogs: $enableDebugLogs]');
      debugPrint('-------------------------------------');
    }
  }
}
