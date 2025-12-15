// ==================== features/auth/data/datasources/auth_remote_datasource.dart ====================
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> getProfile();

  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    return response['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password},
      requiresAuth: false,
    );

    return response['data'] as Map<String, dynamic>;
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get(
      ApiEndpoints.profile,
      requiresAuth: true,
    );

    final userData = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.refresh,
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    return response['data']['token'] as String;
  }
}
