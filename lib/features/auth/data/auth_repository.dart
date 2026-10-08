import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _storageService.saveToken(token);
      await _storageService.saveUser(user.toJson());

      return user;
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Registration successful. You can now sign in.';
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _storageService.saveUser(user.toJson());
      return user;
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<User> updateProfile({required String name}) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiConstants.profile,
        data: {'name': name.trim()},
      );
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _storageService.saveUser(user.toJson());
      return user;
    } catch (e) {
      throw ApiException(_apiClient.extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
  }

  Future<User?> checkAuth() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return null;

    final cachedUserMap = _storageService.getUser();
    if (cachedUserMap != null) {
      return User.fromJson(cachedUserMap);
    }

    try {
      return await getProfile();
    } catch (_) {
      return null;
    }
  }
}
