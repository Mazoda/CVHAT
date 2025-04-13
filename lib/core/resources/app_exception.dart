class AppException implements Exception {
  final dynamic message;

  AppException([this.message]);

  @override
  String toString() {
    Object? message = this.message ?? "Something went wrong";
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
