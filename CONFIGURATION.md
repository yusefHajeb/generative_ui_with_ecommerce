# Application Configuration Guide

## Overview

This application uses a secure configuration management system that keeps API keys and sensitive data out of the codebase using compile-time constants via `--dart-define` flags.

## Quick Start

### For Development

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your API keys:**
   ```bash
   # Edit the file and add your actual API key
   nano .env
   ```

3. **Run the app using the helper script:**
   ```bash
   ./run_dev.sh
   ```

   Or use the VS Code/Android Studio launch configuration named "Development".

### For Production

Never use the `.env` file in production. Instead, pass secrets via `--dart-define`:

```bash
flutter build apk \
  --dart-define=GEMINI_API_KEY=$PROD_API_KEY \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## Configuration Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GEMINI_API_KEY` | ✅ Yes | - | Your Gemini API key for AI features |
| `GEMINI_MODEL` | ❌ No | `gemini-2.0-flash` | Gemini model to use |
| `GEMINI_BASE_URL` | ❌ No | `https://generativelanguage.googleapis.com/v1beta` | Gemini API base URL |
| `FAKE_STORE_API_URL` | ❌ No | `https://fakestoreapi.com` | Fake Store API endpoint |
| `DUMMY_JSON_API_URL` | ❌ No | `https://dummyjson.com` | DummyJSON API endpoint |
| `MAX_RETRIES` | ❌ No | `3` | Maximum retry attempts for failed API calls |

## Security Architecture

### Why Not flutter_dotenv?

This project uses `String.fromEnvironment()` instead of `flutter_dotenv` because:

1. **No Asset Bundling**: `.env` files bundled as assets can be extracted from APK/IPA files
2. **Compile-Time Injection**: Values are injected during compilation, not loaded at runtime
3. **Better Obfuscation**: When combined with `--obfuscate`, keys are harder to reverse-engineer
4. **CI/CD Friendly**: Works seamlessly with secret management in CI/CD pipelines

### How It Works

```dart
// Configuration is read at compile-time
static const String _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
```

When you run:
```bash
flutter run --dart-define=GEMINI_API_KEY=abc123
```

The value `abc123` is compiled into the binary, not stored as a plain text asset.

## Development Workflows

### Option 1: Using run_dev.sh (Recommended)

```bash
# Make sure .env file exists with your keys
./run_dev.sh
```

This script automatically loads variables from `.env` and passes them as `--dart-define` flags.

### Option 2: Using launch.json

Open the project in VS Code or Android Studio and select the "Development" launch configuration. This is pre-configured to load values from the `.env` file.

### Option 3: Manual Command

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_key_here \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash
```

## Production Deployment

### CI/CD Integration

#### GitHub Actions Example

```yaml
name: Build Production APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build APK
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          flutter build apk \
            --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY \
            --dart-define=GEMINI_MODEL=gemini-2.0-flash \
            --obfuscate \
            --split-debug-info=build/debug-info
```

#### GitLab CI Example

```yaml
build:
  stage: build
  script:
    - flutter build apk
        --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
        --dart-define=GEMINI_MODEL=gemini-2.0-flash
        --obfuscate
  variables:
    GEMINI_API_KEY: $GEMINI_API_KEY
```

### Environment-Specific Builds

Create different build scripts for each environment:

**build_dev.sh:**
```bash
flutter build apk \
  --dart-define=GEMINI_API_KEY=$DEV_API_KEY \
  --flavor dev
```

**build_staging.sh:**
```bash
flutter build apk \
  --dart-define=GEMINI_API_KEY=$STAGING_API_KEY \
  --flavor staging
```

**build_prod.sh:**
```bash
flutter build apk \
  --dart-define=GEMINI_API_KEY=$PROD_API_KEY \
  --flavor production \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## Usage in Code

### Via Provider (Recommended)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/providers/configuration_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configurationServiceProvider);
    final apiKey = config.geminiApiKey;
    
    // Use the configuration...
    return Text('Using model: ${config.geminiModel}');
  }
}
```

### Via Constructor Injection

```dart
import 'package:generative_ui_with_ecommerce/core/services/configuration_service.dart';

class ApiService {
  final IConfigurationService config;
  
  ApiService(this.config);
  
  Future<void> makeRequest() async {
    final url = '${config.geminiBaseUrl}/endpoint';
    final headers = {'Authorization': 'Bearer ${config.geminiApiKey}'};
    // Make API call...
  }
}
```

## Security Best Practices

### ✅ DO

- Store production API keys in CI/CD secret vaults
- Use different API keys for dev/staging/production
- Enable code obfuscation for production builds: `--obfuscate`
- Rotate API keys regularly
- Use API keys with minimal required permissions
- Keep `.env` in `.gitignore`

### ❌ DON'T

- Commit `.env` file to version control
- Hardcode API keys in source code
- Use production keys in development
- Share API keys in chat/email
- Bundle `.env` as an app asset
- Use the same key across all environments

## Troubleshooting

### Error: "GEMINI_API_KEY not configured"

**Cause:** The app was run without providing the API key.

**Solution:** 
- Use `./run_dev.sh` script
- Or pass `--dart-define=GEMINI_API_KEY=your_key` when running
- Or use the launch configuration in your IDE

### Error: ".env file not found"

**Cause:** The `.env` file doesn't exist.

**Solution:**
```bash
cp .env.example .env
# Edit .env and add your API key
```

### Keys not working in production build

**Cause:** Forgot to pass `--dart-define` flags during build.

**Solution:** Always pass configuration via `--dart-define` when building:
```bash
flutter build apk --dart-define=GEMINI_API_KEY=$YOUR_KEY
```

## Migration from Hardcoded Keys

If you're migrating from hardcoded API keys:

1. **Find all hardcoded keys:**
   ```bash
   grep -r "AIza" lib/
   ```

2. **Replace with configuration service:**
   ```dart
   // Before
   static const String apiKey = 'AIzaSy...';
   
   // After
   final config = ref.watch(configurationServiceProvider);
   final apiKey = config.geminiApiKey;
   ```

3. **Update your run/build commands** to include `--dart-define` flags

4. **Remove hardcoded keys** from the codebase

## Additional Resources

- [Flutter Environment Variables](https://docs.flutter.dev/deployment/flavors)
- [Dart Compile-Time Constants](https://dart.dev/guides/language/language-tour#compile-time-constants)
- [Securing API Keys in Flutter](https://docs.flutter.dev/deployment/obfuscate)

## Support

For issues or questions about configuration:
1. Check this guide first
2. Review `lib/core/services/README.md`
3. Check the example files: `.env.example`, `launch.json`
4. Contact the development team
