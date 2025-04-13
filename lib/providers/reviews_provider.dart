import 'package:cvhat/app_router.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:toastification/toastification.dart';
import '../core/resources/internet_exception.dart';
import '../models/review_model.dart';
import '../services/internet_connection_service.dart';
import '../services/reviews_service.dart';

class ReviewsProvider extends ChangeNotifier {
  final ReviewsService _reviewsService = ReviewsService.reviewsService;

  List<Review> _reviews = [];
  List<Review> _recentReviews = [];
  List<Review> _favoriteReviews = [];
  String _aiReviewsCount = "0";
  String _recruiterReviewsCount = "0";
  final LocalStorageService localStorageService =
      LocalStorageService.localStorageService;

  bool _isLoading = false;

  List<Review> get reviews => _reviews;

  List<Review> get favoriteReviews => _favoriteReviews;

  List<Review> get recentReviews => _recentReviews;

  String get aiReviewsCount => _aiReviewsCount;

  String get recruiterReviewsCount => _recruiterReviewsCount;

  bool get isLoading => _isLoading;

  Future<void> fetchAllReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      _reviews = (await _reviewsService.fetchAllReviews(userToken!)).data;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentReviews() async {
    _isLoading = true;
    notifyListeners();
    if (kDebugMode) {
      print("test in fetch provider");
    }
    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      ApiResponse<List<Review>> responseData =
          await _reviewsService.fetchRecentReviews(userToken!);
      _recentReviews = responseData.data;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavoriteReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      _favoriteReviews =
          (await _reviewsService.fetchFavoriteReviews(userToken!)).data;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReviewsCounts() async {
    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      final response = await _reviewsService.fetchReviewsCounts(userToken!);
      _aiReviewsCount = response.data["aiReviewCount"].toString();
      _recruiterReviewsCount = response.data["recruiterReviewCount"].toString();
      notifyListeners();
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  clearAllReviewsLists() {
    _reviews.clear();
    _recentReviews.clear();
    _favoriteReviews.clear();
    _aiReviewsCount = "0";
    notifyListeners();
  }
}
