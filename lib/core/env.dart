import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경변수 접근 헬퍼.
/// .env 파일이 누락된 키를 가지고 있으면 즉시 throw — fail-fast.
class Env {
  static String _required(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('.env에 $key 가 설정되어 있지 않습니다');
    }
    return value;
  }

  static String _optional(String key, [String fallback = '']) =>
      dotenv.env[key] ?? fallback;

  // Supabase
  static String get supabaseUrl => _required('SUPABASE_URL');
  static String get supabaseAnonKey => _required('SUPABASE_ANON_KEY');

  // Kakao
  static String get kakaoNativeAppKey => _optional('KAKAO_NATIVE_APP_KEY');
  static String get kakaoJavascriptKey => _optional('KAKAO_JAVASCRIPT_KEY');

  // Google
  static String get googleClientIdWeb => _optional('GOOGLE_CLIENT_ID_WEB');

  // App
  static String get appName => _optional('APP_NAME', 'Voyna');
  static String get appBundleId => _optional('APP_BUNDLE_ID', 'app.voyna');
}
