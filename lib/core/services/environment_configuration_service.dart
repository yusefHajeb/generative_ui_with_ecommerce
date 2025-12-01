import 'configuration_service.dart';

class EnvironmentConfigurationService implements IConfigurationService {
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static const String _geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.0-flash',
  );

  static const String _geminiBaseUrl = String.fromEnvironment(
    'GEMINI_BASE_URL',
    defaultValue: 'https://generativelanguage.googleapis.com/v1beta',
  );

  static const String _fakeStoreApiUrl = String.fromEnvironment(
    'FAKE_STORE_API_URL',
    defaultValue: 'https://fakestoreapi.com',
  );

  static const String _dummyJsonApiUrl = String.fromEnvironment(
    'DUMMY_JSON_API_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const int _maxRetries = int.fromEnvironment('MAX_RETRIES', defaultValue: 3);

  @override
  String get geminiApiKey {
    if (_geminiApiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not configured. '
        'Please provide it via --dart-define=GEMINI_API_KEY=your_key '
        'when building or running the app.',
      );
    }
    return _geminiApiKey;
  }

  @override
  String get geminiModel => _geminiModel;

  @override
  int get maxRetries => _maxRetries;

  @override
  String get geminiBaseUrl => _geminiBaseUrl;

  @override
  String get fakeStoreApiUrl => _fakeStoreApiUrl;

  @override
  String get dummyJsonApiUrl => _dummyJsonApiUrl;
}
