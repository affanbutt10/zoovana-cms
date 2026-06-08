/// Abstraction over device permission requests and checks.
///
/// This service provides a platform-agnostic interface for requesting and
/// checking device permissions. Concrete implementations can delegate to
/// packages such as `permission_handler` when added to the project.
class PermissionService {
  /// Requests the given [permission] from the operating system.
  ///
  /// Returns `true` if the permission was granted, `false` otherwise.
  Future<bool> requestPermission(AppPermission permission) async {
    // Scaffold: replace with real permission_handler calls when the package
    // is added to pubspec.yaml.
    //
    // Example with permission_handler:
    //   final status = await Permission.camera.request();
    //   return status.isGranted;
    return true;
  }

  /// Checks whether the given [permission] is currently granted without
  /// prompting the user.
  ///
  /// Returns `true` if the permission is already granted, `false` otherwise.
  Future<bool> checkPermission(AppPermission permission) async {
    // Scaffold: replace with real permission_handler calls when the package
    // is added to pubspec.yaml.
    //
    // Example with permission_handler:
    //   final status = await Permission.camera.status;
    //   return status.isGranted;
    return true;
  }
}

/// Enumeration of permissions the app may need to request.
///
/// Extend this enum as new permissions are required.
enum AppPermission { camera, gallery, location, notification, storage }
