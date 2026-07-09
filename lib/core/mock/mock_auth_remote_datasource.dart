import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/models/login_response_model.dart';
import '../../features/auth/data/models/role_model.dart';

/// Mock implementation of [AuthRemoteDataSource] for UI testing.
///
/// Returns instant success responses without hitting any network.
/// Swap this in via [DependencyInjection] by setting [useMocks = true].
///
/// Mock credentials: any email + password "password" → success
///                   any email + password "wrong"    → unauthorized error
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<LoginResponseModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate latency

    // In demo/mock mode any non-empty credentials succeed.
    return LoginResponseModel.fromJson({
      'access_token': 'mock_access_token_abc123',
      'refresh_token': 'mock_refresh_token_xyz789',
      'expires_in': 1800,
      'user': {
        'id': 'mock-user-001',
        'email': email,
        'full_name': 'Ahmed Al-Rashid',
        'is_superuser': false,
        'is_email_verified': true,
        'roles': [
          {'id': 'role-001', 'name': 'shop_owner', 'scope': 'tenant'},
        ],
        'default_tenant_id': 'tenant-001',
      },
    });
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> verifyEmail({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Any OTP works in mock mode
  }

  @override
  Future<void> resendVerification(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'mock_new_access_token_refreshed';
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      RoleModel.fromJson({
        'id': 'role-001',
        'name': 'shop_owner',
        'scope': 'tenant',
      }),
    ];
  }
}
