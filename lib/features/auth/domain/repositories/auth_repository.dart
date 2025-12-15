// ==================== features/auth/domain/repositories/auth_repository.dart ====================
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getProfile();

  Future<Either<Failure, String>> refreshToken(String refreshToken);

  Future<void> logout();

  Future<String?> getStoredToken();

  Future<bool> isLoggedIn();
}
