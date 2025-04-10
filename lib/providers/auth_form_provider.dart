import 'package:flutter/material.dart';

class AuthFormProvider extends ChangeNotifier {
  AuthFormProvider._();

  static AuthFormProvider authFormProvider = AuthFormProvider._();
  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String required = "";
  String emailError = "";
  String passwordError = "";
  String confirmPasswordError = "";

  void validateEmail() {
    String email = emailController.text;
    emailError = email.isEmpty
        ? 'Email is required'
        : (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)
            ? 'Enter a valid email'
            : "");
    notifyListeners();
  }

  void validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordError = "Password is required";
    } else if (passwordController.text.length < 8) {
      passwordError = "Password must be at least 8 characters";
    } else {
      passwordError = "";
    }
    notifyListeners();
  }

  void validateConfirmPassword() {
    String confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm Password is required';
    } else if (confirmPassword != passwordController.text) {
      confirmPasswordError = 'Passwords do not match';
    } else {
      confirmPasswordError = "";
    }
    notifyListeners();
  }

  bool validateRequiredLoginForm() {
    return emailController.text.isEmpty || passwordController.text.isEmpty;
  }

  bool validateLoginForm() {
    validateEmail();
    validatePassword();
    return emailError.isEmpty && passwordError.isEmpty;
  }

  bool validateRequiredSignUpForm() {
    return firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty;
  }

  bool validateSignUpForm() {
    validateEmail();
    validatePassword();
    validateConfirmPassword();

    return emailError.isEmpty &&
        passwordError.isEmpty &&
        confirmPasswordError.isEmpty;
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure = !isConfirmPasswordObscure;
    notifyListeners();
  }
}
