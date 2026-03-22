import 'dart:js' as js;

class ApiConfig {
  static String get baseUrl {
    final url = js.context['API_URL'];
    return url ?? 'https://default-api-url.com';
  }
}
