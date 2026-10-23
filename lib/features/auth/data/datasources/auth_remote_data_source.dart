import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await apiClient.post('/auth/login', {'email': email, 'password': password});
  }
}