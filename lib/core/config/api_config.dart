class ApiConfig {
  // Local development
  static const String localBaseUrl = 'http://10.0.2.2:5000';

  // Railway production (سيتم تحديثه بعد النشر)
  static const String productionBaseUrl = 'https://your-app-name.railway.app';

  // Current base URL (تغيير هذا حسب البيئة)
  static const String baseUrl = localBaseUrl;

  // API Endpoints
  static const String customersEndpoint = '$baseUrl/api/customers';
  static const String productsEndpoint = '$baseUrl/api/products';
  static const String invoicesEndpoint = '$baseUrl/api/invoices';
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String reportsEndpoint = '$baseUrl/api/reports';
  static const String dashboardEndpoint = '$baseUrl/api/dashboard';
  static const String supportEndpoint = '$baseUrl/api/support';
  static const String settingsEndpoint = '$baseUrl/api/settings';
  static const String languageEndpoint = '$baseUrl/api/language';

  // Health check
  static const String healthEndpoint = '$baseUrl/api/health';
}
