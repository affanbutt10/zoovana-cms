import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// Injects the `Accept-Language` header on every outgoing request.
///
/// Reads the device locale from [WidgetsBinding.instance.platformDispatcher].
/// If the device language code is `ar`, the header value is `ar`; otherwise
/// it falls back to `en`.
class LocaleInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _resolveLocale();
    handler.next(options);
  }

  /// Returns `'ar'` when the device locale language code is Arabic,
  /// otherwise returns `'en'`.
  String _resolveLocale() {
    final deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return (deviceLocale == 'ar') ? 'ar' : 'en';
  }
}
