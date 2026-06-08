import 'app_env.dart';

/// Holds environment-specific configuration values.
///
/// Use [AppConfig.fromEnv] to obtain the correct configuration for the
/// current [AppEnv].
class AppConfig {
  // ---------------------------------------------------------------------------
  // Service base URLs (used by DioFactory)
  // ---------------------------------------------------------------------------

  /// Base URL for the Auth Service.
  static const String authBaseUrl = 'https://api.auth.zoovana.net';

  /// Base URL for the Shop Service (business & branches init).
  static const String shopBaseUrl = 'https://api.shop.zoovana.net';

  /// Base URL for the CMS Service (dashboard, suppliers, categories, products).
  static const String cmsBaseUrl = 'https://s.zoovana.net';

  // ---------------------------------------------------------------------------
  // Dio timeout constants
  // ---------------------------------------------------------------------------

  /// Timeout for establishing a connection.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Timeout for receiving a response.
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Instance-based env config (legacy — kept for backward compatibility)
  // ---------------------------------------------------------------------------

  /// The base URL for all API requests.
  final String baseUrl;

  /// A human-readable name for the current environment.
  final String envName;

  /// The active environment.
  final AppEnv env;

  const AppConfig._({
    required this.baseUrl,
    required this.envName,
    required this.env,
  });

  /// Returns the [AppConfig] that corresponds to [env].
  factory AppConfig.fromEnv(AppEnv env) {
    switch (env) {
      case AppEnv.dev:
        return const AppConfig._(
          baseUrl: 'https://dev-api.zoovana.com/api/v1',
          envName: 'Development',
          env: AppEnv.dev,
        );
      case AppEnv.staging:
        return const AppConfig._(
          baseUrl: 'https://staging-api.zoovana.com/api/v1',
          envName: 'Staging',
          env: AppEnv.staging,
        );
      case AppEnv.prod:
        return const AppConfig._(
          baseUrl: 'https://api.zoovana.com/api/v1',
          envName: 'Production',
          env: AppEnv.prod,
        );
    }
  }

  /// Convenience getter — returns `true` when running in development.
  bool get isDev => env == AppEnv.dev;

  /// Convenience getter — returns `true` when running in production.
  bool get isProd => env == AppEnv.prod;

  @override
  String toString() => 'AppConfig(env: $envName, baseUrl: $baseUrl)';
}
