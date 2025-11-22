# AI Chat Providers

This directory contains the provider setup for the AI Chat feature, following the same pattern as the Cart feature for consistency.

## Provider Hierarchy

The providers are organized in a hierarchical structure with clear dependencies:

### 1. Configuration Providers (Root Level)
- `configurationServiceProvider` - Provides configuration service (defined in `core/providers/configuration_provider.dart`)

### 2. API Client Providers
- `productApiClientProvider` - Dedicated API client for DummyJSON API
  - Dependencies: None (leaf provider)

### 3. Service Providers
- `productSearchServiceProvider` - Implements `IProductSearchService`
  - Dependencies: `productApiClientProvider`, `configurationServiceProvider`
- `recommendationServiceProvider` - (To be implemented in future task)
  - Dependencies: `productApiClientProvider`, `configurationServiceProvider`

### 4. Cart Providers (AI Chat Context)
- `cartLocalDataSourceProvider` - Local cart storage
  - Dependencies: None (leaf provider)
- `cartRemoteDataSourceProvider` - Remote cart API calls
  - Dependencies: `productApiClientProvider`
- `aiChatCartRepositoryProvider` - Cart repository for AI chat
  - Dependencies: `cartLocalDataSourceProvider`, `cartRemoteDataSourceProvider`
- `cartManagementServiceProvider` - Cart management service
  - Dependencies: `aiChatCartRepositoryProvider`

### 5. Tool Providers
- `toolRegistryProvider` - Manages AI tool definitions
  - Dependencies: None (leaf provider)
- `toolExecutorProvider` - (To be implemented after RecommendationService)
  - Dependencies: `productSearchServiceProvider`, `cartManagementServiceProvider`, `recommendationServiceProvider`, `productApiClientProvider`

### 6. Gemini Service Provider
- `geminiMCPServiceProvider` - Gemini API communication
  - Dependencies: `productApiClientProvider`

### 7. Repository Providers
- `aiChatRepositoryProvider` - AI chat repository
  - Dependencies: `geminiMCPServiceProvider`

### 8. State Management Providers
- `aiChatProvider` - Main chat state notifier (defined in `ai_chat_providers.dart`)
  - Dependencies: `aiChatRepositoryProvider`

## Usage

Import the service providers in your code:

```dart
import 'package:generative_ui_with_ecommerce/features/ai_chat/providers/service_providers.dart';

// Access providers using ref.watch or ref.read
final productSearchService = ref.watch(productSearchServiceProvider);
final aiChatRepository = ref.read(aiChatRepositoryProvider);
```

## Design Principles

1. **Dependency Injection**: All services use constructor injection with interfaces
2. **Single Responsibility**: Each provider has a single, well-defined purpose
3. **Testability**: Interface-based design enables easy mocking for tests
4. **Consistency**: Follows the same pattern as the Cart feature
5. **Clear Dependencies**: Each provider explicitly declares its dependencies

## Requirements Satisfied

- **Requirement 1.4**: Use constructor injection with interfaces to enable testing and flexibility
- **Requirement 1.1**: Organize code into distinct layers (presentation, domain, data)
- **Requirement 1.2**: Isolate business logic in domain layer services

## Future Tasks

- Implement `RecommendationService` and uncomment `recommendationServiceProvider`
- Implement `ToolExecutor` provider after `RecommendationService` is complete
- Refactor `ManageCartService` to properly implement `ICartManagementService` interface
