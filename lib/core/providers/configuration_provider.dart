import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/services/configuration_service.dart';
import 'package:generative_ui_with_ecommerce/core/services/environment_configuration_service.dart';
import 'package:generative_ui_with_ecommerce/core/services/logger_service.dart';

final configurationServiceProvider = Provider<IConfigurationService>((ref) {
  return EnvironmentConfigurationService();
});

final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});
