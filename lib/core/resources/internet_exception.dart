class InternetException implements Exception {
  final dynamic message = "No Internet Connection! Check your connection";

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
