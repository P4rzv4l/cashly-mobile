class ApiConstants {
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost/api/v1');

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // Resources
  static const String accounts = '/accounts';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String creditCards = '/credit-cards';
  static const String goals = '/goals';
  static const String reserves = '/reserves';
  static const String dashboard = '/dashboard';
  static const String aiQuery = '/ai/query';
}
