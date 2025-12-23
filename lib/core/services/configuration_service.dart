/// Interface for configuration management
/// Provides access to application configuration values like API keys and endpoints
abstract class IConfigurationService {
  /// Gemini API key for authentication
  String get geminiApiKey;

  /// Gemini model identifier to use for requests
  String get geminiModel;

  /// Maximum number of retry attempts for failed API calls
  int get maxRetries;

  /// Base URL for Gemini API
  String get geminiBaseUrl;

  /// Fake Store API base URL
  String get fakeStoreApiUrl;

  /// DummyJSON API base URL
  String get dummyJsonApiUrl;
}
