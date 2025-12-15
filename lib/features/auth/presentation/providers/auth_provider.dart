// ==================== features/auth/presentation/providers/auth_provider.dart ====================
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  });

  // Getters
  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Login
  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);

    final result = await loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AuthStatus.error);
        return false;
      },
      (data) {
        final userData = data['user'] as Map<String, dynamic>;
        _user = UserEntity(
          id: userData['_id'],
          name: userData['name'],
          email: userData['email'],
          createdAt: DateTime.parse(userData['createdAt']),
          updatedAt: DateTime.parse(userData['updatedAt']),
        );
        _setStatus(AuthStatus.authenticated);
        return true;
      },
    );
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _setStatus(AuthStatus.loading);

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AuthStatus.error);
        return false;
      },
      (data) {
        final userData = data['user'] as Map<String, dynamic>;
        _user = UserEntity(
          id: userData['_id'],
          name: userData['name'],
          email: userData['email'],
          createdAt: DateTime.parse(userData['createdAt']),
          updatedAt: DateTime.parse(userData['updatedAt']),
        );
        _setStatus(AuthStatus.authenticated);
        return true;
      },
    );
  }

  // Logout
  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  // Check if logged in
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await authRepository.getProfile();
      result.fold((failure) => _setStatus(AuthStatus.unauthenticated), (user) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
      });
    } else {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
