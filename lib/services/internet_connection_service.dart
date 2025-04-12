import 'package:cvhat/constants/api_endpoints.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionService {
  InternetConnectionService._();

  static final InternetConnectionService _instance =
      InternetConnectionService._();

  static InternetConnectionService get instance => _instance;

  final InternetConnection _connection = InternetConnection.createInstance(
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse(ApiEndPoints.connectionStatus)),
    ],
  );

  Future<bool> hasConnection() async {
    return await _connection.hasInternetAccess;
  }
}
