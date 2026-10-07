enum AppEnvironment {
  development,
  production,
}

class Environment {
  static const String _env = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static AppEnvironment get current {
    if (_env == 'production') {
      return AppEnvironment.production;
    }
    return AppEnvironment.development;
  }

  static String get envName => _env;
}
