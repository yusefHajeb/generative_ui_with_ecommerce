/// API Endpoints constants
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.example.com';
  static const String imageBaseUrl = 'https://cdn.example.com';
  static const String fakeStoreBaseUrl = 'https://fakestoreapi.com';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User Profile
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // Products
  static const String products = '/products';
  static String productDetails(String id) => '/products/$id';
  static const String categories = '/categories';
  static String categoryProducts(String categoryId) => '/categories/$categoryId/products';
  static const String searchProducts = '/products/search';

  // Fake Store API
  static const String fakeStoreProducts = '/products';
  static String fakeStoreProductDetails(String id) => '/products/$id';
  static const String fakeStoreCategories = '/products/categories';

  // Shopping Cart
  static const String cart = '/cart';
  static String cartItem(String itemId) => '/cart/items/$itemId';
  static const String cartCheckout = '/cart/checkout';

  // Orders
  static const String orders = '/orders';
  static String orderDetails(String orderId) => '/orders/$orderId';
  static String orderStatus(String orderId) => '/orders/$orderId/status';
  static const String orderHistory = '/orders/history';

  // Wishlist
  static const String wishlist = '/wishlist';
  static String wishlistItem(String itemId) => '/wishlist/$itemId';

  // Reviews
  static String productReviews(String productId) => '/products/$productId/reviews';
  static String addReview(String productId) => '/products/$productId/reviews';
  static String updateReview(String reviewId) => '/reviews/$reviewId';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationDetails(String notificationId) => '/notifications/$notificationId';
  static const String markAsRead = '/notifications/mark-read';

  // Settings
  static const String appSettings = '/settings';
  static const String userPreferences = '/user/preferences';

  // Analytics
  static const String analytics = '/analytics';
  static const String userAnalytics = '/analytics/user';

  // Support
  static const String supportTickets = '/support/tickets';
  static String supportTicket(String ticketId) => '/support/tickets/$ticketId';
  static const String faq = '/support/faq';

  // File Upload
  static const String uploadFile = '/upload/file';
  static const String uploadImage = '/upload/image';

  // WebSocket endpoints (if applicable)
  static const String websocketUrl = 'wss://ws.example.com';

  // Helper methods for dynamic endpoints
  static String buildUrl(String endpoint, [Map<String, dynamic>? params]) {
    String url = endpoint;
    if (params != null && params.isNotEmpty) {
      final queryParams = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url += '?$queryParams';
    }
    return url;
  }

  static String replacePathParams(String endpoint, Map<String, String> pathParams) {
    String url = endpoint;
    pathParams.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return url;
  }
}

/// HTTP Status Codes
class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}

/// Request Headers
class RequestHeaders {
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String userAgent = 'User-Agent';
  static const String cacheControl = 'Cache-Control';
  static const String ifModifiedSince = 'If-Modified-Since';
  static const String etag = 'ETag';
}

/// Content Types
class ContentTypes {
  static const String json = 'application/json';
  static const String formData = 'multipart/form-data';
  static const String urlEncoded = 'application/x-www-form-urlencoded';
  static const String text = 'text/plain';
  static const String html = 'text/html';
  static const String xml = 'application/xml';
}
