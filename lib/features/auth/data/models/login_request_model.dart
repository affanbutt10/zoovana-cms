/// Data-layer model representing the login API request body.
///
/// Serialised to JSON and sent as the POST body to [ApiEndpoints.login].
class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Converts this model to a JSON map suitable for the API request body.
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
