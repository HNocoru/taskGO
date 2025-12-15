// ==================== features/auth/data/repositories/auth_repository_impl.dart ====================
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Guardar token y usuario
      final token = result['token'] as String;
      final refreshToken = result['refreshToken'] as String;
      final userData = result['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveUser(user);

      // Configurar token en ApiClient
      apiClient.setToken(token);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Guardar token y usuario
      final token = result['token'] as String;
      final refreshToken = result['refreshToken'] as String;
      final userData = result['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveUser(user);

      // Configurar token en ApiClient
      apiClient.setToken(token);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await localDataSource.saveUser(user);
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      final newToken = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveToken(newToken);
      apiClient.setToken(newToken);
      return Right(newToken);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
    apiClient.setToken(null);
  }

  @override
  Future<String?> getStoredToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    if (token != null) {
      apiClient.setToken(token);
      return true;
    }
    return false;
  }
}
