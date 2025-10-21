# Network Layer

This directory contains the network layer implementation for the Flutter application, following clean architecture principles and best practices for scalability, maintainability, and performance.

## Architecture Overview

The network layer is structured as follows:

```
lib/core/network/
├── api_client.dart          # Abstract API client interface and implementation
├── dio_client.dart          # Dio client factory and configuration
├── endpoints.dart           # API endpoints and constants
├── interceptors.dart        # Dio interceptors for auth, logging, retry, etc.
├── network_info.dart        # Network connectivity checking
├── network_service.dart     # High-level network service with Riverpod providers
└── README.md               # This documentation
```

## Key Components

### 1. ApiClient (`api_client.dart`)
- **Abstract interface** defining HTTP operations (GET, POST, PUT, DELETE, PATCH)
- **Implementation using Dio** with comprehensive error handling
- **Network connectivity checking** before making requests
- **Automatic error transformation** to custom exceptions

### 2. DioClientFactory (`dio_client.dart`)
- **Factory pattern** for creating configured Dio instances
- **Multiple client types**: standard, upload, download
- **Flexible configuration** with optional interceptors
- **Pre-configured timeouts** and headers

### 3. Interceptors (`interceptors.dart`)
- **AuthInterceptor**: Adds authentication headers and common headers
- **TokenRefreshInterceptor**: Handles automatic token refresh on 401 errors
- **LoggingInterceptor**: Logs requests and responses (development only)
- **CacheInterceptor**: Adds cache control headers
- **RetryInterceptor**: Retries failed requests with exponential backoff

### 4. NetworkInfo (`network_info.dart`)
- **Connectivity checking** using connectivity_plus package
- **Abstract interface** for testability
- **Platform-specific implementations**

### 5. Endpoints (`endpoints.dart`)
- **Centralized API endpoints** management
- **Dynamic endpoint building** with path parameters and query parameters
- **HTTP status codes** and content types constants

### 6. NetworkService (`network_service.dart`)
- **High-level service** wrapping ApiClient
- **Riverpod providers** for dependency injection
- **Simplified API** for common operations

## Usage Examples

### Basic Setup

```dart
// In your main.dart or service locator
final container = ProviderContainer();
final apiClient = container.read(apiClientProvider);
final networkService = container.read(networkServiceProvider);
```

### Making API Calls

```dart
// Using NetworkService (recommended for simple operations)
final products = await networkService.get(ApiEndpoints.products);

// Using ApiClient directly (for complex operations)
final response = await apiClient.post(
  ApiEndpoints.login,
  data: {'email': 'user@example.com', 'password': 'password'}
);
```

### File Upload

```dart
// Using specialized upload client
final uploadClient = DioClientFactory.createUploadDio();
final result = await uploadClient.post(
  ApiEndpoints.uploadImage,
  data: FormData.fromMap({
    'file': await MultipartFile.fromFile(imageFile.path),
  }),
);
```

### Error Handling

```dart
try {
  final result = await networkService.get(ApiEndpoints.userProfile);
  // Handle success
} on AppException catch (e) {
  // Handle custom exceptions (network errors, auth errors, etc.)
  print('Error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

## Best Practices

### 1. Dependency Injection
Use Riverpod providers for injecting network dependencies:

```dart
class UserRepository {
  final NetworkService _networkService;

  UserRepository(this._networkService);

  Future<User> getUserProfile() async {
    final response = await _networkService.get(ApiEndpoints.userProfile);
    return User.fromJson(response);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return UserRepository(networkService);
});
```

### 2. Error Handling
Always wrap network calls in try-catch blocks and handle specific error types:

```dart
Future<Either<Failure, User>> getUserProfile() async {
  try {
    final response = await _networkService.get(ApiEndpoints.userProfile);
    final user = User.fromJson(response);
    return Right(user);
  } on AppException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(CacheFailure('Unexpected error occurred'));
  }
}
```

### 3. Request/Response Models
Create dedicated models for requests and responses:

```dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        user = User.fromJson(json['user']);
}
```

### 4. Testing
The network layer is designed to be easily testable:

```dart
void main() {
  late MockApiClient mockApiClient;
  late NetworkService networkService;

  setUp(() {
    mockApiClient = MockApiClient();
    networkService = NetworkService(mockApiClient);
  });

  test('should return user profile when API call is successful', () async {
    // Arrange
    final userJson = {'id': 1, 'name': 'John Doe'};
    when(mockApiClient.get(any)).thenAnswer((_) async => userJson);

    // Act
    final result = await networkService.get(ApiEndpoints.userProfile);

    // Assert
    expect(result, userJson);
    verify(mockApiClient.get(ApiEndpoints.userProfile));
  });
}
```

## Configuration

### Environment-Specific Setup
Create different configurations for development, staging, and production:

```dart
class NetworkConfig {
  static const String devBaseUrl = 'https://dev-api.example.com';
  static const String stagingBaseUrl = 'https://staging-api.example.com';
  static const String prodBaseUrl = 'https://api.example.com';

  static String get baseUrl {
    // Return appropriate URL based on environment
    return prodBaseUrl; // or devBaseUrl, stagingBaseUrl
  }
}
```

### Custom Interceptors
Add custom interceptors for specific requirements:

```dart
class CustomHeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Custom-Header'] = 'custom-value';
    super.onRequest(options, handler);
  }
}
```

## Performance Considerations

1. **Connection Pooling**: Dio automatically handles connection pooling
2. **Request Caching**: Use CacheInterceptor for GET requests
3. **Retry Logic**: Automatic retry with exponential backoff
4. **Timeout Configuration**: Appropriate timeouts for different operations
5. **Logging**: Enable logging only in development builds

## Security Considerations

1. **HTTPS Only**: Always use HTTPS in production
2. **Certificate Pinning**: Implement certificate pinning for enhanced security
3. **Token Storage**: Use secure storage for sensitive tokens
4. **Input Validation**: Validate all inputs before making requests
5. **Rate Limiting**: Implement rate limiting to prevent abuse

## Maintenance

- **Regular Updates**: Keep Dio and other dependencies updated
- **Code Reviews**: Review network-related code changes carefully
- **Documentation**: Keep API documentation in sync with code
- **Monitoring**: Implement network request monitoring in production
- **Testing**: Maintain comprehensive test coverage for network operations
