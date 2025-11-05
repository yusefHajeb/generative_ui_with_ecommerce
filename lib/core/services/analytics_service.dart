import 'dart:async';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:generative_ui_with_ecommerce/core/errors/failure.dart';
import 'package:generative_ui_with_ecommerce/core/models/cloudflare_trace_model.dart';
import 'package:generative_ui_with_ecommerce/core/network/api_client.dart';
import 'package:generative_ui_with_ecommerce/core/network/network_service.dart';

class AnalyticsService extends NetworkService {
  static const String _cloudflareTraceUrl = 'https://www.cloudflare.com/cdn-cgi/trace';

  AnalyticsService(super.apiClient);

  /// Fetch Cloudflare trace data for user analytics
  Future<Either<Failure, CloudflareTraceModel>> fetchCloudflareTrace() async {
    try {
      // Use Isolate to perform network operation off main thread
      final receivePort = ReceivePort();
      await Isolate.spawn((SendPort port) async {
        try {
          // Create a simple Dio instance for this isolate
          final response = await handleDirectApiRequest<CloudflareTraceModel>(
            endPoint: _cloudflareTraceUrl,
            httpMethod: HttpMethod.get,
            fromJson: (p1) => CloudflareTraceModel.fromTraceResponse(p1),
          );

          port.send(response);
        } catch (e) {
          port.send('Isolate error: ${e.toString()}');
        }
      }, receivePort.sendPort);

      final completer = Completer<Either<Failure, CloudflareTraceModel>>();
      receivePort.listen((message) {
        if (message is CloudflareTraceModel) {
          completer.complete(Right(message));
        } else if (message is String) {
          completer.complete(Left(ServerFailure(message)));
        }
        receivePort.close();
      });

      return completer.future;
    } catch (e) {
      return Left(ServerFailure('Failed to fetch analytics data: ${e.toString()}'));
    }
  }

  /// Isolate function to fetch trace data

  /// Alternative method using Completer for async initialization
  Future<Either<Failure, CloudflareTraceModel>> fetchCloudflareTraceWithCompleter() async {
    final completer = Completer<Either<Failure, CloudflareTraceModel>>();

    try {
      final response = await apiClient.safeApiCall(
        httpMethod: HttpMethod.get,
        endPoint: _cloudflareTraceUrl,
      );

      if (response.statusCode == 200 && response.data is String) {
        final traceModel = CloudflareTraceModel.fromTraceResponse(response.data);
        completer.complete(Right(traceModel));
      } else {
        completer.complete(
          Left(ServerFailure('HTTP ${response.statusCode}: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      completer.complete(Left(ServerFailure(e.toString())));
    }

    return completer.future;
  }

  String? getUserLocation(CloudflareTraceModel trace) {
    return trace.location;
  }

  String? getUserIP(CloudflareTraceModel trace) {
    return trace.ip;
  }

  /// Utility method to get user agent from trace data
  String? getUserAgent(CloudflareTraceModel trace) {
    return trace.userAgent;
  }

  bool isHttpsConnection(CloudflareTraceModel trace) {
    return trace.visitScheme == 'https';
  }

  String? getTlsVersion(CloudflareTraceModel trace) {
    return trace.tlsVersion;
  }

  String? getDatacenter(CloudflareTraceModel trace) {
    return trace.datacenter;
  }
}
