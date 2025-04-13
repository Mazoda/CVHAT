import 'package:cvhat/constants/api_endpoints.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/models/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class ProfileService {
  ProfileService._();

  static ProfileService profileService = ProfileService._();
  final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => true));

  Future<ApiResponse<Profile>> getUserProfile(String userToken) async {
    try {
      final response = await _dio.get(ApiEndPoints.getProfile,
          options: Options(
            headers: {
              "Authorization": "Bearer $userToken",
            },
          ));
      if (response.statusCode == 200) {
        final Map<String, dynamic> profile = response.data["data"]["profile"];

        if (profile.isNotEmpty) {
          return ApiResponse.success(
              data: Profile.fromJson(profile),
              message: response.data["message"][0]);
        }
      }
      return ApiResponse.failure(message: response.data["message"]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<Profile>> postAvatar(
      String userToken, PlatformFile avatarFile) async {
    try {
      MultipartFile multiPartFile = await MultipartFile.fromFile(
        avatarFile.path!,
        filename: avatarFile.name,
        // TODO: add jpeg in accepted types
        contentType: DioMediaType("image", "jpg"),
      );
      FormData data = FormData.fromMap({'avatar': multiPartFile});
      Response response = await _dio.post(
        ApiEndPoints.postAvatar,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: Profile.fromJson(response.data["data"]["profile"]),
            message: response.data["message"][0]);
      }
      return ApiResponse.failure(message: response.data["message"]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<Profile>> updateUserName(
      String userToken, String firstName, String lastName) async {
    try {
      Map<String, dynamic> data = {
        "firstName": firstName,
        "lastName": lastName,
      };

      Response response = await _dio.post(
        ApiEndPoints.postUserName,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: Profile.fromJson(response.data["data"]["profile"]),
            message: response.data["message"][0]);
      }
      return ApiResponse.failure(message: response.data["message"]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse> changePassword(
      String userToken, String oldPassword, String newPassword) async {
    try {
      Map<String, dynamic> data = {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      };

      Response response = await _dio.post(
        ApiEndPoints.postNewPassword,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: [], message: response.data["message"][0]);
      }
      return ApiResponse.failure(message: response.data["message"]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }
}
