import 'package:cvhat/constants/api_endpoints.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OTPService {
  OTPService._();

  static OTPService otpService = OTPService._();
  final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => true));

  Future<ApiResponse<dynamic>> sendOtp(String email) async {
    try {
      Response response = await _dio.post(
        ApiEndPoints.sendOtp,
        data: {"email": email},
      );
      if (kDebugMode) {
        print("-------------------${response.data}");
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("OTP sent successfully");
          print(response.data["message"]);
        }
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

  Future<ApiResponse<dynamic>> verifyOtp(String email, String otpCode) async {
    try {
      Response response = await _dio.post(
        ApiEndPoints.verifyOtp,
        data: {"email": email, "otp": otpCode},
      );
      if (kDebugMode) {
        print("-------------------${response.data}");
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("OTP verified successfully");
          print(response.data["message"]);
        }
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

  Future<ApiResponse<dynamic>> resetPassword(
      String token, String newPassword) async {
    try {
      Response response = await _dio.post(
        ApiEndPoints.resetPassword,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "newPassword": newPassword,
        },
      );

      if (kDebugMode) {
        print("-------------------${response.data}");
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Password reset successfully");
          print(response.data["message"]);
        }
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
