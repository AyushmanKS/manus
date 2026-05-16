import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  Future<Response<ResponseBody>> postStream(
    final String url, {
    final Map<String, dynamic>? data,
    final Map<String, dynamic>? headers,
    final CancelToken? cancelToken,
  }) async {
    return _dio.post<ResponseBody>(
      url,
      data: data,
      options: Options(responseType: ResponseType.stream, headers: headers),
      cancelToken: cancelToken,
    );
  }
}