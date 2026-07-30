import 'package:codevault/core/config/api_environment.dart';
import 'package:dio/dio.dart';
import '../security/token_store.dart';

class ApiClient {
  ApiClient({Dio? dio, TokenStore? tokenStore, this.onSessionExpired})
    : _tokenStore = tokenStore ?? TokenStore.create(),
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEnvironment.resolve(),
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.read();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStore.delete();
            await onSessionExpired?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStore _tokenStore;
  final Future<void> Function()? onSessionExpired;
}
