import 'package:cvhat/app_router.dart';
import 'package:cvhat/models/cv_model.dart';
import 'package:cvhat/models/review_model.dart';
import 'package:cvhat/providers/reviews_provider.dart';
import 'package:cvhat/services/local_storage_service.dart';
import 'package:cvhat/services/reviews_service.dart';
import 'package:cvhat/views/feedback_screen/feedback_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart' show ToastificationType;

import '../core/resources/internet_exception.dart';
import '../services/internet_connection_service.dart';

class FeedBackProvider extends ChangeNotifier {
  final LocalStorageService localStorageService =
      LocalStorageService.localStorageService;
  final ReviewsService _reviewsService = ReviewsService.reviewsService;
  TextEditingController submitCvController = TextEditingController();
  CV? postCVResponse;
  Review? singleFeedBack;
  bool isReviewFavorite = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAnalyzing = false;
  PlatformFile? selectedCV;

  bool get isUploading => _isUploading;

  bool get isAnalyzing => _isAnalyzing;

  bool get isLoading => _isLoading;

  toggleIsReviewFavorite() {
    isReviewFavorite = !isReviewFavorite;
    notifyListeners();
  }

  Future<void> fetchReviewByID(int reviewId) async {
    _isLoading = true;
    singleFeedBack = null;
    isReviewFavorite = false;
    notifyListeners();
    AppRouter.pushWidget(const FeedbackPage());

    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      Review review =
          (await _reviewsService.fetchReviewByID(userToken!, reviewId)).data;
      singleFeedBack = review;
      isReviewFavorite = singleFeedBack!.isFavorite;
      notifyListeners();
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postCV(PlatformFile? selectedFile) async {
    _isUploading = true;
    notifyListeners();
    try {
      if (selectedFile == null) {
        AppRouter.toastificationSnackBar(
            "Error", "Please Select a File", ToastificationType.error);
        return;
      }
      if (submitCvController.text.isEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", "Please Enter a Title", ToastificationType.error);
        return;
      }
      if (selectedFile.extension != "pdf") {
        AppRouter.toastificationSnackBar(
            "Error", "Please select  a PDF file", ToastificationType.error);
        return;
      }
      if (kDebugMode) {
        print("Uploading cv in provider Cv in Service");
      }
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      postCVResponse =
          (await _reviewsService.postCV(userToken!, selectedFile)).data;
      notifyListeners();
      if (postCVResponse != null) {
        await postAIReview();
      }
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future postAIReview() async {
    singleFeedBack = null;
    isReviewFavorite = false;
    _isAnalyzing = true;
    notifyListeners();
    AppRouter.pushWithReplacement(const FeedbackPage());
    try {
      if (kDebugMode) {
        print("getting review in provider Cv in Service");
        print("CV id is:${postCVResponse!.id!}");
      }
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      singleFeedBack = (await _reviewsService.postAiReview(
              userToken!, postCVResponse!.id!, submitCvController.text))
          .data;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future toggleFavorite() async {
    try {
      _isLoading = true;
      notifyListeners();
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }

      if (singleFeedBack == null) {
        AppRouter.toastificationSnackBar(
            "Error", "Review Not Found", ToastificationType.error);
        return;
      }

      String? userToken = await localStorageService.getUserToken();
      await _reviewsService.toggleFavorite(userToken!, singleFeedBack!.id);
      await Provider.of<ReviewsProvider>(AppRouter.navKey.currentContext!,
              listen: false)
          .fetchFavoriteReviews();
      toggleIsReviewFavorite();
      isReviewFavorite
          ? AppRouter.toastificationSnackBar(
              "Success", "Added to your Favorites.", ToastificationType.info)
          : AppRouter.toastificationSnackBar("Success",
              "Removed From your Favorites.", ToastificationType.info);
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
