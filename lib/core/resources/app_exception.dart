class AppException implements Exception {
  final dynamic message;

  AppException([this.message]);

  @override
  String toString() {
    return message ?? "Something went wrong";
  }
}
