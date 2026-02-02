// ==========================================
// CORE - CONSTANTS
// ==========================================

class ApiConstants {
  static const String baseUrl = 'https://diabetics-api.jljimenez.es';
  static const String apiVersion = '/api/v1';
  
  // Endpoints
  static const String health = '/health';
  static const String register = '$apiVersion/users/register';
  static const String login = '$apiVersion/auth/login';
  static const String calculateBolus = '$apiVersion/nutrition/calculate-bolus';
  static const String ingredients = '$apiVersion/nutrition/ingredients';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String uiMode = 'ui_mode'; // 'adult' or 'child'
}

enum UiMode {
  adult,
  child;
  
  bool get isAdult => this == UiMode.adult;
  bool get isChild => this == UiMode.child;
}

enum DiabetesType {
  type1('type_1'),
  type2('type_2'),
  gestational('gestational'),
  lada('lada'),
  mody('mody');
  
  const DiabetesType(this.value);
  final String value;
}
