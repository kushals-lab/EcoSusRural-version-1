import '../datasources/scheme_remote_data_source.dart';
import '../../domain/entities/scheme_entity.dart';

class SchemeRepositoryImpl {
  final SchemeRemoteDataSource remoteDataSource;
  SchemeRepositoryImpl(this.remoteDataSource);

  Future<List<SchemeEntity>> fetchSchemes() async {
    final data = await remoteDataSource.getSchemes() as List;
    return data.map((item) => SchemeEntity(id: item['id'], name: item['name'], amount: item['amount'])).toList();
  }
}