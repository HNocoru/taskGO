// ==================== features/auth/data/datasources/auth_local_datasource.dart ====================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> saveUser(UserModel user);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await sharedPreferences.setString(
      AppConstants.refreshTokenKey,
      refreshToken,
    );
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.userKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return sharedPreferences.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<UserModel?> getUser() async {
    final userString = sharedPreferences.getString(AppConstants.userKey);

    if (userString == null) return null;

    try {
      final userJson = json.decode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw CacheException('Error al obtener usuario guardado');
    }
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
    await sharedPreferences.remove(AppConstants.refreshTokenKey);
    await sharedPreferences.remove(AppConstants.userKey);
  }
}
