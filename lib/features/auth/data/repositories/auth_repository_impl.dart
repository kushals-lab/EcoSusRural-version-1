import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  Future<UserEntity> login(String email, String password) async {
    final res = await remoteDataSource.login(email, password);
    return UserEntity(id: res['id'] ?? '1', email: email, token: res['token'] ?? 'mock_token');
  }
}