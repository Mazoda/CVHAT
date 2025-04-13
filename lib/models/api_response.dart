class ApiResponse<T> {
  final T data;
  final String message;
  final bool success;

  factory ApiResponse.success({required T data, String message = "Success"}) {
    return ApiResponse(data: data, message: message, success: true);
  }

  factory ApiResponse.failure({required String message}) {
    return ApiResponse(data: [] as dynamic, message: message, success: false);
  }

  factory ApiResponse.networkError() {
    return ApiResponse(
        data: [] as dynamic,
        message: "Network Error, Please check your connection!",
        success: false);
  }

  factory ApiResponse.unknownError() {
    return ApiResponse(
        data: [] as dynamic,
        message: "Something went wrong, Please try again!",
        success: false);
  }

  ApiResponse(
      {required this.data, required this.message, required this.success});
}
