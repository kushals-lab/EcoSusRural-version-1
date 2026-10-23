import '../../../../core/network/api_client.dart';

class SchemeRemoteDataSource {
  final ApiClient apiClient;
  SchemeRemoteDataSource(this.apiClient);

  Future<dynamic> getSchemes() async {
    return await apiClient.get('/schemes');
  }
}