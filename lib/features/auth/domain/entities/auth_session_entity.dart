import 'user_entity.dart';

/// Represents the lifecycle status of an authentication session.
enum AuthSessionStatus {
  /// The session is active and the user is fully authenticated.
  active,

  /// The user is authenticated but their account is pending approval.
  pendingApproval,
}

/// Domain-layer representation of an authenticated session.
///
/// Produced by [LoginResponseModel.toEntity()] and consumed by
/// [AuthController] to drive navigation and state.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    required this.status,
  });

  /// The JWT access token for authenticating API requests.
  final String accessToken;

  /// The refresh token used to obtain a new access token.
  final String refreshToken;

  /// Token lifetime in seconds from the time of issuance.
  final int expiresIn;

  /// The authenticated user's domain entity.
  final UserEntity user;

  /// The current status of this session.
  final AuthSessionStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionEntity &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresIn == other.expiresIn &&
          user == other.user &&
          status == other.status;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      expiresIn.hashCode ^
      user.hashCode ^
      status.hashCode;

  @override
  String toString() =>
      'AuthSessionEntity(accessToken: [redacted], refreshToken: [redacted], '
      'expiresIn: $expiresIn, user: $user, status: $status)';
}
