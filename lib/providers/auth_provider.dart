import 'package:cvhat/app_router.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/providers/auth_form_provider.dart';
import 'package:cvhat/providers/reviews_provider.dart';
import 'package:cvhat/services/local_storage_service.dart';
import 'package:cvhat/views/auth/register_screen.dart';
import 'package:cvhat/views/home_screen/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../core/resources/internet_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/internet_connection_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.authService;
  final LocalStorageService localStorageService =
      LocalStorageService.localStorageService;
  final AuthFormProvider authFormProvider = AuthFormProvider.authFormProvider;
  bool isLoading = false;
  late dynamic user;

  Future login() async {
    if (authFormProvider.validateRequiredLoginForm()) {
      AppRouter.toastificationSnackBar(
          "Error", "All Fields Are Required!", ToastificationType.error);
      isLoading = false;
      notifyListeners();
      return;
    }

    if (!authFormProvider.validateLoginForm()) {
      String emailError = authFormProvider.emailError;
      String passError = authFormProvider.passwordError;
      if (emailError.isNotEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", emailError, ToastificationType.error);
      }
      if (passError.isNotEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", passError, ToastificationType.error);
      }
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String email = authFormProvider.emailController.text;
      String password = authFormProvider.passwordController.text;
      final ApiResponse responseData =
          await _authService.login(email, password);
      if (!responseData.success) {
        return AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
      }
      final userData = responseData.data;
      user = User.fromJson(userData);

      await localStorageService.saveUserData(
        token: user.token,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
      );
      AppRouter.pushWithReplacement(HomePage());
      AppRouter.toastificationSnackBar(
          "Success", responseData.message, ToastificationType.success);
      authFormProvider.clearControllers();
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    final userData = await localStorageService.loadUserData();
    if (kDebugMode) {
      print(userData);
    }
    if (userData['auth_token'] != null) {
      user = User(
        token: userData['auth_token']!,
        firstName: userData['first_name']!,
        lastName: userData['last_name']!,
        email: userData['email']!,
      );
    } else {
      user = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      notifyListeners();
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      ApiResponse responseData = await _authService.logout(userToken!);
      if (!responseData.success) {
        AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
        return;
      }

      AppRouter.pushAndRemoveUntil(const RegisterScreen());
      user = null;
      await localStorageService.clearUserData();
      Provider.of<ReviewsProvider>(AppRouter.navKey.currentContext!,
              listen: false)
          .clearAllReviewsLists();
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp() async {
    if (authFormProvider.validateRequiredSignUpForm()) {
      AppRouter.toastificationSnackBar(
          "Error", "All Fields Are Required!", ToastificationType.error);
      return false;
    }
    if (!authFormProvider.validateSignUpForm()) {
      if (authFormProvider.emailError.isNotEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", authFormProvider.emailError, ToastificationType.error);
      }
      if (authFormProvider.passwordError.isNotEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", authFormProvider.passwordError, ToastificationType.error);
      }
      if (authFormProvider.confirmPasswordError.isNotEmpty) {
        AppRouter.toastificationSnackBar("Error",
            authFormProvider.confirmPasswordError, ToastificationType.error);
      }
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String firstName = authFormProvider.firstNameController.text;
      String lastName = authFormProvider.lastNameController.text;
      String email = authFormProvider.emailController.text;
      String password = authFormProvider.passwordController.text;
      final ApiResponse responseData = await _authService.signUp(
        firstName,
        lastName,
        email,
        password,
      );
      if (!responseData.success) {
        AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
        return responseData.success;
      }
      AppRouter.toastificationSnackBar(
          "Success", responseData.message, ToastificationType.success);
      authFormProvider.clearControllers();
      return responseData.success;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
