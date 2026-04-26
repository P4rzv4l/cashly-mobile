import 'package:dio/dio.dart';
import 'package:cashly/core/api/auth_storage.dart';
import 'package:cashly/core/constants/api_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        // Don't throw on 4xx/5xx — let us handle them
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    _dio.interceptors.addAll([
      // Auth interceptor
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Treat 4xx/5xx as errors manually so we get clean DioException
          if (response.statusCode != null && response.statusCode! >= 400) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: _extractMessage(response.data, response.statusCode),
              ),
              true,
            );
          } else {
            handler.next(response);
          }
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AuthStorage.clear();
          }
          handler.next(error);
        },
      ),
      // Log interceptor (debug only)
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => print('[API] $o'),
      ),
    ]);
  }

  static ApiClient get instance => _instance ??= ApiClient._();

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  static String _extractMessage(dynamic data, int? statusCode) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values
            .expand((v) => v is List ? v : [v])
            .firstOrNull;
        if (first != null) return first.toString();
      }
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'Erro ${statusCode ?? ''}';
  }

  /// Extract a friendly error message from any exception
  static String errorMessage(dynamic error, [String fallback = 'Algo deu errado']) {
    if (error is DioException) {
      // Server returned a response with error status
      final serverMsg = _extractMessage(error.response?.data, error.response?.statusCode);
      if (serverMsg.isNotEmpty && !serverMsg.startsWith('Erro ')) return serverMsg;

      // Network / timeout errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Tempo limite excedido. Verifique sua conexão.';
        case DioExceptionType.connectionError:
          return 'Sem conexão com o servidor. Verifique sua rede.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          if (code == 500) return 'Erro interno no servidor (500). Tente novamente em instantes.';
          if (code == 404) return 'Recurso não encontrado (404).';
          if (code == 403) return 'Sem permissão para acessar este recurso.';
          return 'Erro do servidor (${code ?? '?'})';
        default:
          return error.message ?? fallback;
      }
    }
    return fallback;
  }
}
