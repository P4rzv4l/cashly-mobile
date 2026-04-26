import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/api/api_client.dart';
import 'package:cashly/core/api/auth_storage.dart';
import 'package:cashly/core/constants/api_constants.dart';
import 'package:cashly/data/models/models.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => token != null;

  AuthState copyWith({String? token, User? user, bool? isLoading, String? error}) =>
      AuthState(
        token: token ?? this.token,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await AuthStorage.getToken();
    final userJson = await AuthStorage.getUser();
    if (token != null && userJson != null) {
      state = AuthState(token: token, user: User.fromJson(userJson));
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await AuthStorage.setToken(token);
      await AuthStorage.setUser(user.toJson());
      state = AuthState(token: token, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.errorMessage(e, 'Falha ao entrar'));
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await AuthStorage.setToken(token);
      await AuthStorage.setUser(user.toJson());
      state = AuthState(token: token, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.errorMessage(e, 'Falha ao criar conta'));
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post(ApiConstants.logout);
    } catch (_) {}
    await AuthStorage.clear();
    state = const AuthState();
  }

  Future<void> updateProfile({String? name, String? phone, double? monthlyIncome}) async {
    try {
      final res = await ApiClient.instance.patch(
        ApiConstants.profile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (monthlyIncome != null) 'monthly_income': monthlyIncome,
        },
      );
      final user = User.fromJson(res.data['data'] as Map<String, dynamic>);
      await AuthStorage.setUser(user.toJson());
      state = state.copyWith(user: user);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
