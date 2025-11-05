import 'package:generative_ui_with_ecommerce/core/network/base_model.dart';

/// Model representing Cloudflare trace data for user behavior analytics
class CloudflareTraceModel implements BaseModel {
  final String? httpVersion;
  final String? host;
  final String? ip;
  final double? timestamp;
  final String? visitScheme;
  final String? userAgent;
  final String? datacenter;
  final String? sliverName;
  final String? httpProtocol;
  final String? location;
  final String? tlsVersion;
  final String? serverNameIndication;
  final String? warpStatus;
  final String? gatewayStatus;
  final String? rayId;
  final String? keyExchange;

  const CloudflareTraceModel({
    this.httpVersion,
    this.host,
    this.ip,
    this.timestamp,
    this.visitScheme,
    this.userAgent,
    this.datacenter,
    this.sliverName,
    this.httpProtocol,
    this.location,
    this.tlsVersion,
    this.serverNameIndication,
    this.warpStatus,
    this.gatewayStatus,
    this.rayId,
    this.keyExchange,
  });

  /// Factory constructor to parse Cloudflare trace response
  factory CloudflareTraceModel.fromTraceResponse(String response) {
    final Map<String, String> data = {};
    final lines = response.split('\n');

    for (final line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          data[parts[0]] = parts[1];
        }
      }
    }

    return CloudflareTraceModel(
      httpVersion: data['fl'],
      host: data['h'],
      ip: data['ip'],
      timestamp: data['ts'] != null ? double.tryParse(data['ts']!) : null,
      visitScheme: data['visit_scheme'],
      userAgent: data['uag'],
      datacenter: data['colo'],
      sliverName: data['sliver'],
      httpProtocol: data['http'],
      location: data['loc'],
      tlsVersion: data['tls'],
      serverNameIndication: data['sni'],
      warpStatus: data['warp'],
      gatewayStatus: data['gateway'],
      rayId: data['rbi'],
      keyExchange: data['kex'],
    );
  }

  @override
  CloudflareTraceModel fromJson(Map<String, dynamic> json) {
    return CloudflareTraceModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fl': httpVersion,
      'h': host,
      'ip': ip,
      'ts': timestamp,
      'visitScheme': visitScheme,
      'uag': userAgent,
      'colo': datacenter,
      'sliver': sliverName,
      'http': httpProtocol,
      'loc': location,
      'tls': tlsVersion,
      'sni': serverNameIndication,
      'warp': warpStatus,
      'gateway': gatewayStatus,
      'rbi': rayId,
      'kex': keyExchange,
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() {
    return '{"fl":"$httpVersion","h":"$host","ip":"$ip","ts":$timestamp,"visitScheme":"$visitScheme","uag":"$userAgent","colo":"$datacenter","sliver":"$sliverName","http":"$httpProtocol","loc":"$location","tls":"$tlsVersion","sni":"$serverNameIndication","warp":"$warpStatus","gateway":"$gatewayStatus","rbi":"$rayId","kex":"$keyExchange"}';
  }

  factory CloudflareTraceModel.fromJson(Map<String, dynamic> json) {
    return CloudflareTraceModel(
      httpVersion: json['fl'] as String?,
      host: json['h'] as String?,
      ip: json['ip'] as String?,
      timestamp: json['ts'] as double?,
      visitScheme: json['visitScheme'] as String?,
      userAgent: json['uag'] as String?,
      datacenter: json['colo'] as String?,
      sliverName: json['sliver'] as String?,
      httpProtocol: json['http'] as String?,
      location: json['loc'] as String?,
      tlsVersion: json['tls'] as String?,
      serverNameIndication: json['sni'] as String?,
      warpStatus: json['warp'] as String?,
      gatewayStatus: json['gateway'] as String?,
      rayId: json['rbi'] as String?,
      keyExchange: json['kex'] as String?,
    );
  }

  @override
  String toString() {
    return 'CloudflareTraceModel(httpVersion: $httpVersion, host: $host, ip: $ip, timestamp: $timestamp, visitScheme: $visitScheme, userAgent: $userAgent, datacenter: $datacenter, sliverName: $sliverName, httpProtocol: $httpProtocol, location: $location, tlsVersion: $tlsVersion, serverNameIndication: $serverNameIndication, warpStatus: $warpStatus, gatewayStatus: $gatewayStatus, rayId: $rayId, keyExchange: $keyExchange)';
  }
}
