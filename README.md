# Generative UI with Ecommerce

A Flutter application demonstrating modern mobile development practices with a focus on clean architecture, state management, and user experience. The app integrates with the Fake Store API to display products in an e-commerce style interface.

## 🏗️ Project Structure

This project follows **Clean Architecture** principles with feature-based organization:

```
lib/
├── core/                          # Core application layer
│   ├── constants/                 # App-wide constants
│   ├── errors/                    # Error handling (exceptions, failures)
│   ├── extention/                 # Dart extensions
│   ├── helper/                    # Utility helpers (shared preferences)
│   ├── network/                   # Network layer (see network README)
│   │   ├── api_client.dart        # HTTP client abstraction
│   │   ├── dio_client.dart        # Dio client factory
│   │   ├── endpoints.dart         # API endpoints configuration
│   │   ├── interceptors.dart      # Dio interceptors (auth, logging, etc.)
│   │   ├── network_info.dart      # Connectivity checking
│   │   ├── network_service.dart   # High-level network service
│   │   └── README.md             # Network layer documentation
│   ├── provider/                  # Riverpod providers
│   ├── routes/                    # App routing (GoRouter)
│   ├── theme/                     # Theme configuration
│   ├── utiles/                    # Utility widgets/animations
│   └── widgets/                   # Shared UI components
├── features/                      # Feature-based modules
│   ├── ai_chat/                   # AI Chat feature (placeholder)
│   ├── home_page/                 # Home screen feature
│   │   ├── presentation/          # UI layer
│   │   │   ├── home_screen.dart   # Home screen widget
│   │   │   └── widgets/           # Home-specific widgets
│   │   └── provider/              # Home-specific providers
│   └── products/                  # Products feature
│       ├── data/                  # Data layer
│       │   ├── models/            # Data models (Product, Rating)
│       │   └── repositories/      # Repository implementations
│       └── presentation/          # Presentation layer
│           ├── providers/         # State management (Riverpod)
│           ├── screens/           # Screen widgets
│           └── widgets/           # Feature-specific widgets
└── main.dart                      # App entry point
```

## 🏛️ Architecture Overview

### Clean Architecture Layers

1. **Presentation Layer** (`features/*/presentation/`)
   - UI components and screens
   - State management with Riverpod
   - User interaction handling

2. **Domain Layer** (Business Logic)
   - Use cases and business rules
   - Repository interfaces
   - Domain entities

3. **Data Layer** (`features/*/data/`)
   - Repository implementations
   - Data models and DTOs
   - External API integrations

4. **Core Layer** (`core/`)
   - Shared utilities and services
   - Network layer abstraction
   - Error handling
   - Theme and constants

### State Management

The app uses **Riverpod** for state management:
- `AsyncNotifier` for async operations (products, categories)
- Provider pattern for dependency injection
- Automatic state updates and error handling

### Network Layer

See [`core/network/README.md`](lib/core/network/README.md) for detailed network layer documentation.

## 🚀 Features

### ✅ Products Feature

A complete e-commerce product browsing experience:

#### Data Layer
- **Models**: `Product` and `Rating` models extending `BaseModel`
- **Repository**: `ProductsRepository` with methods for:
  - Fetching all products
  - Fetching products by category
  - Fetching product details
  - Fetching categories

#### Presentation Layer
- **Providers**: Riverpod async notifiers for products and categories
- **Screen**: `ProductsScreen` with:
  - Grid layout for products
  - Category filter chips
  - Pull-to-refresh functionality
  - Error handling with retry
  - Loading states with shimmer effects
- **Widget**: `ProductCard` displaying:
  - Product image (with caching)
  - Title, category, price
  - Rating and review count
  - Truncated description

#### Key Features
- **Category Filtering**: Horizontal scrollable chips for category selection
- **Responsive Design**: Grid layout adapting to screen size
- **Image Caching**: Efficient image loading with `CachedNetworkImage`
- **Error Recovery**: Comprehensive error handling with user-friendly messages
- **State Management**: Reactive UI updates with Riverpod

### 🏠 Home Page Feature

- Simple navigation hub
- Button to access products screen
- Clean, minimal design

### 🔮 Future Features

- **AI Chat**: Placeholder for AI-powered features
- **Shopping Cart**: Add/remove products
- **User Authentication**: Login/signup flow
- **Product Details**: Detailed product view
- **Search**: Product search functionality

## 🛠️ Technical Stack

### Core Dependencies
- **Flutter**: UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Dio**: HTTP client
- **GoRouter**: Navigation
- **CachedNetworkImage**: Image caching

### Development Tools
- **Flutter SDK**: 3.0+
- **Dart SDK**: 3.0+
- **Android Studio/VS Code**: IDE
- **Flutter DevTools**: Debugging

## 📱 API Integration

### Fake Store API
- **Base URL**: `https://fakestoreapi.com`
- **Endpoints**:
  - `GET /products` - All products
  - `GET /products/categories` - Product categories
  - `GET /products/category/{category}` - Products by category
  - `GET /products/{id}` - Product details

### Data Models
```dart
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;
}

class Rating {
  final double rate;
  final int count;
}
```

## 🎨 UI/UX Design

### Design System
- **Colors**: Primary color scheme with consistent theming
- **Typography**: Hierarchical text styles
- **Components**: Reusable widgets (cards, buttons, chips)
- **Layout**: Responsive grid and list layouts

### User Experience
- **Loading States**: Shimmer effects during data fetching
- **Error Handling**: User-friendly error messages with retry options
- **Navigation**: Smooth transitions between screens
- **Accessibility**: Proper contrast and touch targets

## 🧪 Testing Strategy

### Unit Tests
- Repository methods
- Provider logic
- Utility functions

### Widget Tests
- UI component rendering
- User interactions
- State changes

### Integration Tests
- API integration
- Navigation flows
- End-to-end user journeys

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio or VS Code
- Android/iOS emulator or device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd generative_ui_with_ecommerce
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

```bash
# Debug build
flutter run --debug

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📋 Development Guidelines

### Code Style
- Follow Dart/Flutter best practices
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused

### State Management
- Use Riverpod for all state management
- Prefer AsyncNotifier for async operations
- Implement proper error handling
- Keep providers focused on single responsibilities

### Network Requests
- Always check connectivity before API calls
- Implement proper error handling
- Use appropriate HTTP methods
- Cache responses when beneficial

### UI Development
- Use responsive design principles
- Implement loading and error states
- Follow Material Design guidelines
- Optimize for performance

## 🔧 Configuration

### Environment Variables
- API base URLs
- Feature flags
- Debug settings

### Build Flavors
- Development
- Staging
- Production

## 📊 Performance Considerations

- **Image Optimization**: Cached network images
- **List Virtualization**: Efficient grid rendering
- **State Updates**: Minimal rebuilds with Riverpod
- **Memory Management**: Proper disposal of resources

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Ensure code quality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Fake Store API](https://fakestoreapi.com) for providing sample e-commerce data
- Flutter community for excellent documentation and packages
- Open source contributors for the amazing tools used in this project
