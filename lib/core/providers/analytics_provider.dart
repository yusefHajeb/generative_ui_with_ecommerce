import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/helper/shared_prefrence.dart';
import 'package:generative_ui_with_ecommerce/core/models/cloudflare_trace_model.dart';
import 'package:generative_ui_with_ecommerce/core/providers/network_provider.dart';
import 'package:generative_ui_with_ecommerce/core/services/analytics_service.dart';

/// Provider for analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsService(apiClient);
});

/// Notifier for Cloudflare trace data
class CloudflareTraceNotifier extends AsyncNotifier<CloudflareTraceModel?> {
  @override
  Future<CloudflareTraceModel?> build() async {
    final analyticsService = ref.watch(analyticsServiceProvider);

    // Try to load from local storage first
    final storedData = await SharedPrefrenceHelper.getString('cloudflare_trace');
    if (storedData != null) {
      return await _fetchAndStoreTrace(analyticsService);
    } else {
      return await _fetchAndStoreTrace(analyticsService);

      // No stored data, fetch fresh
    }
  }

  /// Fetch and store trace data
  Future<CloudflareTraceModel?> _fetchAndStoreTrace(AnalyticsService analyticsService) async {
    final result = await analyticsService.fetchCloudflareTraceWithCompleter();

    return result.fold(
      (failure) {
        // On failure, return null but don't throw
        return null;
      },
      (traceModel) async {
        // Store in local storage
        await SharedPrefrenceHelper.setData('cloudflare_trace', traceModel.toJsonString());
        return traceModel;
      },
    );
  }

  /// Refresh the trace data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for Cloudflare trace data using AsyncNotifier
final cloudflareTraceProvider =
    AsyncNotifierProvider<CloudflareTraceNotifier, CloudflareTraceModel?>(
      CloudflareTraceNotifier.new,
    );

/// Provider for user location from trace data
final userLocationProvider = Provider<String?>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.location, orElse: () => null);
});

/// Provider for user IP from trace data
final userIPProvider = Provider<String?>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.ip, orElse: () => null);
});

/// Provider for user agent from trace data
final userAgentProvider = Provider<String?>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.userAgent, orElse: () => null);
});

/// Provider for connection security status
final isHttpsProvider = Provider<bool>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.visitScheme == 'https', orElse: () => false);
});

/// Provider for TLS version
final tlsVersionProvider = Provider<String?>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.tlsVersion, orElse: () => null);
});

/// Provider for Cloudflare datacenter
final datacenterProvider = Provider<String?>((ref) {
  final traceAsync = ref.watch(cloudflareTraceProvider);
  return traceAsync.maybeWhen(data: (trace) => trace?.datacenter, orElse: () => null);
});

/// Provider to refresh analytics data
final refreshAnalyticsProvider = Provider<Future<void> Function()>((ref) {
  final notifier = ref.watch(cloudflareTraceProvider.notifier);
  return notifier.refresh;
});
