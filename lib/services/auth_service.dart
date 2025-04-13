import 'package:cvhat/constants/api_endpoints.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService._();

  static AuthService authService = AuthService._();
  final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => true));

  Future<ApiResponse<dynamic>> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        ApiEndPoints.userLogin,
        data: {"email": email, "password": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: response.data["data"], message: response.data["message"][0]);
      } else {
        return ApiResponse.failure(message: response.data["message"][0]);
      }
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<dynamic>> signUp(
      String firstName, String lastName, String email, String password) async {
    try {
      Response response = await _dio.post(ApiEndPoints.userSignup,
          data: {
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
          },
          options: Options(headers: {"Content-Type": "application/json"}));
      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: response.data["data"], message: response.data["message"][0]);
      } else {
        return ApiResponse.failure(message: response.data["message"][0]);
      }
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<dynamic>> logout(String userToken) async {
    try {
      Response response = await _dio.post(
        ApiEndPoints.userLogout,
        options: Options(
          headers: {"Authorization": "Bearer $userToken"},
        ),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: response.data["data"], message: response.data["message"][0]);
      } else {
        return ApiResponse.failure(message: response.data["message"][0]);
      }
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }
}
