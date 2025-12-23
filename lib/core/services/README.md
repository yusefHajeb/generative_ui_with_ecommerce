# Configuration Service

## Overview

The configuration service provides a secure interface for accessing application configuration values like API keys, endpoints, and other settings using compile-time constants via `--dart-define`.

## Security Approach

This implementation uses `String.fromEnvironment()` and `int.fromEnvironment()` which read compile-time constants passed via `--dart-define` flags. This is more secure than bundling `.env` files because:

1. **No Asset Bundling**: API keys are NOT included in app assets
2. **Compile-Time Injection**: Values are injected during build, not runtime
3. **Obfuscation**: When combined with code obfuscation, keys are harder to extract
4. **Environment Separation**: Different keys for dev/staging/prod without code changes

## Usage

### 1. Access via Provider (Recommended)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/providers/configuration_provider.dart';

class MyService extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configurationServiceProvider);
    final apiKey = config.geminiApiKey;
    // Use the API key...
  }
}
```

### 2. Constructor Injection

```dart
import 'package:generative_ui_with_ecommerce/core/services/configuration_service.dart';

class GeminiService {
  final IConfigurationService config;
  
  GeminiService(this.config);
  
  Future<void> makeRequest() async {
    final apiKey = config.geminiApiKey;
    // Use the API key...
  }
}
```

## Configuration Variables

The following variables can be configured via `--dart-define`:

- `GEMINI_API_KEY` (required): Your Gemini API key
- `GEMINI_MODEL` (optional): Model to use (default: gemini-2.0-flash)
- `GEMINI_BASE_URL` (optional): Base URL for Gemini API
- `FAKE_STORE_API_URL` (optional): Fake Store API URL
- `DUMMY_JSON_API_URL` (optional): DummyJSON API URL
- `MAX_RETRIES` (optional): Maximum retry attempts (default: 3)

## Setup

### Development

Use the provided `launch.json` configuration or run:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_key_here \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash
```

### Production Build

```bash
flutter build apk \
  --dart-define=GEMINI_API_KEY=$PROD_API_KEY \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash \
  --obfuscate \
  --split-debug-info=build/debug-info
```

### CI/CD Integration

Store secrets in your CI/CD environment variables and pass them during build:

```yaml
# GitHub Actions example
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }} \
      --obfuscate
```

### Local Development with .env file

For convenience during development, you can source the `.env` file:

```bash
# Load .env and run
export $(cat .env | xargs) && flutter run \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY \
  --dart-define=GEMINI_MODEL=$GEMINI_MODEL
```

Or use the provided `launch.json` configurations in VS Code/Android Studio.

## Security Best Practices

1. **Never commit `.env`**: It's in `.gitignore` for a reason
2. **Use CI/CD secrets**: Store production keys in secure CI/CD vaults
3. **Enable obfuscation**: Always use `--obfuscate` for production builds
4. **Rotate keys**: Regularly rotate API keys
5. **Limit key permissions**: Use API keys with minimal required permissions

## Benefits

- **Security**: Keys not bundled in app assets
- **Flexibility**: Different configs per environment without code changes
- **Testability**: Easy to mock configuration in tests
- **Type Safety**: Interface ensures all required values are provided
- **CI/CD Friendly**: Works seamlessly with build pipelines
