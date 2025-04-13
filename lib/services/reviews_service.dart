import 'package:cvhat/constants/api_endpoints.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/models/cv_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/review_model.dart';

class ReviewsService {
  ReviewsService._();

  static ReviewsService reviewsService = ReviewsService._();
  final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => true));
  final Dio _dioPostCV = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (status) => true));

  Future<ApiResponse<List<Review>>> _fetchReviews(
      String userToken, String endpoint) async {
    try {
      Response response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reviews = response.data["data"]["reviews"];
        return ApiResponse.success(
            data: reviews.map((json) => Review.fromJson(json)).toList());
      }
      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<Review>> fetchReviewByID(
      String userToken, int reviewID) async {
    try {
      final response = await _dio.get(
        "${ApiEndPoints.getUserReviews}/$reviewID",
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
            // Include userToken in headers
          },
        ),
      );

      if (response.statusCode == 200 && response.data["status"] == "success") {
        final reviewJson =
            response.data["data"]["review"]; // Extract first review
        return ApiResponse.success(data: Review.fromJson(reviewJson));
      }
      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<List<Review>>> fetchAllReviews(String userToken) async {
    return await _fetchReviews(userToken, ApiEndPoints.getUserReviews);
  }

  Future<ApiResponse<List<Review>>> fetchRecentReviews(String userToken) async {
    return await _fetchReviews(userToken, ApiEndPoints.getUserRecentReviews);
  }

  Future<ApiResponse<List<Review>>> fetchFavoriteReviews(
      String userToken) async {
    return await _fetchReviews(userToken, ApiEndPoints.getUserFavoriteReviews);
  }

  Future<ApiResponse<Map<String, int>>> fetchReviewsCounts(
      String userToken) async {
    try {
      final response = await _dio.get(
        ApiEndPoints.getUserReviewsCount,
        options: Options(
          headers: {
            "Authorization":
                "Bearer $userToken", // Include userToken in headers
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(data: {
          "aiReviewCount": response.data["data"]["aiReviewCount"],
          "recruiterReviewCount": response.data["data"]["recruiterReviewCount"]
        });
      }
      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<CV>> postCV(String userToken, PlatformFile pdfFile) async {
    try {
      MultipartFile multiPartFile = await MultipartFile.fromFile(
        pdfFile.path!,
        filename: pdfFile.name,
        contentType: DioMediaType("application", "pdf"),
      );

      FormData data = FormData.fromMap({'cv': multiPartFile});
      Response response = await _dioPostCV.post(
        ApiEndPoints.postUserCv,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: CV.fromJson(response.data["data"]["cv"]));
      }

      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<Review>> postAiReview(
      String userToken, int cvID, String title) async {
    try {
      print("getting review in Service");
      Response response = await _dioPostCV.post(
        ApiEndPoints.postAiReview,
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
        data: {"cv": cvID, "title": title},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
            data: Review.fromJson(response.data["data"]["review"]));
      }
      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }

  Future<ApiResponse<bool>> toggleFavorite(
      String userToken, int reviewID) async {
    try {
      Response response = await _dio.post(
        "${ApiEndPoints.toggleFavorite}/$reviewID",
        options: Options(
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(data: true);
      }
      return ApiResponse.failure(message: response.data["message"][0]);
    } on DioException {
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.unknownError();
    }
  }
}
