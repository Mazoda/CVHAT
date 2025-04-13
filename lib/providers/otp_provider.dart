import 'package:cvhat/app_router.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../core/resources/internet_exception.dart';
import '../services/internet_connection_service.dart';

class OTPProvider extends ChangeNotifier {
  final OTPService _otpService = OTPService.otpService;

  bool _isLoading = false;
  bool _nextStep = false;
  String? _token;

  bool get isLoading => _isLoading;

  bool get nextStep => _nextStep;

  TextEditingController email = TextEditingController();

  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();

  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmNewPassword = TextEditingController();

  String getOtpCode() {
    return otp1.text.trim() +
        otp2.text.trim() +
        otp3.text.trim() +
        otp4.text.trim();
  }

  Future<void> sendOtp() async {
    _isLoading = true;
    _nextStep = false;
    notifyListeners();

    try {
      String trimmedEmail = email.text.trim();

      if (trimmedEmail.isEmpty) {
        AppRouter.toastificationSnackBar(
            "Error", "Please enter your email", ToastificationType.error);
        return;
      }

      final emailRegex =
          RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
      if (!emailRegex.hasMatch(trimmedEmail)) {
        AppRouter.toastificationSnackBar(
            "Error", "Invalid email format", ToastificationType.error);
        return;
      }
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      final ApiResponse responseData = await _otpService.sendOtp(trimmedEmail);

      if (!responseData.success) {
        _nextStep = false;
        AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
        clearControllers();
        return;
      }
      _nextStep = true;
      AppRouter.toastificationSnackBar(
          "Success", "OTP sent successfully!", ToastificationType.success);
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp() async {
    _isLoading = true;
    _nextStep = false;
    notifyListeners();

    try {
      if (!isValidOtp(getOtpCode())) {
        AppRouter.toastificationSnackBar(
            "Error", "OTP must be 4 digits", ToastificationType.error);
        return;
      }
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      final ApiResponse responseData =
          await _otpService.verifyOtp(email.text.trim(), getOtpCode());

      if (!responseData.success) {
        _nextStep = false;
        AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
        return;
      }
      _token = responseData.data["token"];
      _nextStep = true;
      AppRouter.toastificationSnackBar(
          "Success", responseData.message, ToastificationType.success);
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword() async {
    _nextStep = false;

    if (_token == null) {
      AppRouter.toastificationSnackBar("Error",
          "OTP verification is required first", ToastificationType.error);
      return;
    }

    if (newPassword.text.length < 8 || newPassword.text.isEmpty) {
      AppRouter.toastificationSnackBar(
          "Error",
          "Password must be at least 8 characters long!",
          ToastificationType.error);
      notifyListeners();
      return;
    }

    if (newPassword.text.trim() != confirmNewPassword.text.trim()) {
      AppRouter.toastificationSnackBar(
          "Error",
          "New password and confirm password do not match!",
          ToastificationType.error);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      final ApiResponse responseData =
          await _otpService.resetPassword(_token!, newPassword.text.trim());

      if (!responseData.success) {
        _nextStep = false;
        AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
        return;
      }

      _nextStep = true;
      AppRouter.toastificationSnackBar(
          "Success", responseData.message, ToastificationType.success);
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearControllers() {
    email.clear();
    otp1.clear();
    otp2.clear();
    otp3.clear();
    otp4.clear();
    newPassword.clear();
    confirmNewPassword.clear();
    notifyListeners();
  }

  bool isValidOtp(String otp) {
    final otpRegex = RegExp(r'^\d{4}$');
    return otpRegex.hasMatch(otp);
  }
}
