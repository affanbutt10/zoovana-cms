import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

/// Data-layer model that parses the login API response.
///
/// Constructed via [LoginResponseModel.fromJson] from the raw API response
/// body. Call [toEntity] to obtain the domain-layer [AuthSessionEntity].
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  /// The JWT access token for authenticating subsequent API requests.
  final String accessToken;

  /// The refresh token used to obtain a new access token.
  final String refreshToken;

  /// Token lifetime in seconds from the time of issuance.
  final int expiresIn;

  /// The authenticated user's data model.
  final UserModel user;

  /// Parses a [LoginResponseModel] from the API response JSON map.
  ///
  /// Supports both the real API envelope `{"success": true, "data": {...}}`
  /// and the flat structure used by mocks / legacy code.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Unwrap the `data` envelope if present (real API response shape)
    final Map<String, dynamic> d =
        (json['data'] as Map<String, dynamic>?) ?? json;

    return LoginResponseModel(
      accessToken: (d['access_token'] as String?) ?? '',
      refreshToken: (d['refresh_token'] as String?) ?? '',
      expiresIn: (d['expires_in'] as num?)?.toInt() ?? 3600,
      user: UserModel.fromJson(d['user'] as Map<String, dynamic>),
    );
  }

  /// Converts this data-layer model to the domain-layer [AuthSessionEntity].
  ///
  /// The session status is always set to [AuthSessionStatus.active] on a
  /// successful login response. Pending-approval detection is handled
  /// separately by the repository layer.
  AuthSessionEntity toEntity() => AuthSessionEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    user: user.toEntity(),
    status: AuthSessionStatus.active,
  );
}
