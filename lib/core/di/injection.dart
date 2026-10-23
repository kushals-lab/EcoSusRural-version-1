import '../network/api_client.dart';
import '../storage/local_storage.dart';

class DependencyInjection {
  static final ApiClient apiClient = ApiClient();
  static final LocalStorage localStorage = LocalStorage();

  static Future<void> init() async {
    await localStorage.init();
  }
}