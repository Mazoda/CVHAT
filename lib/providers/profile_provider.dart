import 'package:cvhat/app_router.dart';
import 'package:cvhat/models/api_response.dart';
import 'package:cvhat/models/profile_model.dart';
import 'package:cvhat/services/local_storage_service.dart';
import 'package:cvhat/services/profile_service.dart';
import 'package:cvhat/views/auth/register_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:toastification/toastification.dart';

import '../core/resources/internet_exception.dart';
import '../services/internet_connection_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService.profileService;
  Profile? _profile;

  Profile? get profile => _profile;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  PlatformFile? selectedFile;

  bool _isChangePassword = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final LocalStorageService localStorageService =
      LocalStorageService.localStorageService;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      ApiResponse responseData =
          await _profileService.getUserProfile(userToken!);
      if (!responseData.success) {
        return AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
      }
      _profile = responseData.data;
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      if (selectedFile != null) {
        await _postAvatar();
      }
      if (firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty) {
        await _updateUserName();
      }

      if (oldPasswordController.text.isNotEmpty &&
          newPasswordController.text.isNotEmpty) {
        _isChangePassword = true;
        notifyListeners();
        await _changePassword();
      }
      if (selectedFile == null &&
          firstNameController.text.isEmpty &&
          lastNameController.text.isEmpty &&
          oldPasswordController.text.isEmpty &&
          newPasswordController.text.isEmpty) {
        return;
      }

      clearFile();
      _clearControllers();
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _postAvatar() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (selectedFile == null) {
        AppRouter.toastificationSnackBar(
            "Error", "Please Select Avatar!", ToastificationType.error);
        return;
      }
      // TODO: accept jpeg and png avatar type
      if (selectedFile!.extension != "jpg") {
        AppRouter.toastificationSnackBar(
            "Error", "Please select jpg file", ToastificationType.error);
        return;
      }
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      ApiResponse responseData =
          await _profileService.postAvatar(userToken!, selectedFile!);
      if (!responseData.success) {
        return AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
      }
      _profile = responseData.data;
      notifyListeners();
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

  Future<void> _updateUserName() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (!await InternetConnectionService.instance.hasConnection()) {
        throw InternetException();
      }
      String? userToken = await localStorageService.getUserToken();
      ApiResponse<Profile> responseData = await _profileService.updateUserName(
          userToken!,
          firstNameController.text.trim(),
          lastNameController.text.trim());
      if (!responseData.success) {
        return AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
      }
      _profile = responseData.data;
      notifyListeners();
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

  Future<void> _changePassword() async {
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
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
      String? userToken = await localStorageService.getUserToken();
      ApiResponse responseData = await _profileService.changePassword(
          userToken!,
          oldPasswordController.text.trim(),
          newPasswordController.text.trim());
      if (!responseData.success) {
        return AppRouter.toastificationSnackBar(
            "Error", responseData.message, ToastificationType.error);
      }
      AppRouter.toastificationSnackBar(
          "Success", responseData.message, ToastificationType.success);
      await localStorageService.clearUserData();
      AppRouter.pushAndRemoveUntil(const RegisterScreen());
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickFile({List<String>? allowedExtensions}) async {
    try {
      _isLoading = true;
      notifyListeners();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.image,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFile = result.files.first;
      } else {
        AppRouter.toastificationSnackBar(
            "Error", "No file selected.", ToastificationType.error);
      }
    } catch (e) {
      AppRouter.toastificationSnackBar(
          "Error", e.toString().split(":")[1], ToastificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFile() {
    selectedFile = null;
    notifyListeners();
  }

  void _clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }
}
