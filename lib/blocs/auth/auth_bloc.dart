import 'package:bloc/bloc.dart';
import 'package:digi4_mobile/models/user_model.dart';
import 'package:digi4_mobile/services/auth_service.dart';
import 'package:meta/meta.dart';
import 'package:digi4_mobile/routes.dart';
import 'package:flutter/widgets.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginEvent>(_handleLoginRequested);
    on<AuthRegisterEvent>(_handleRegisterRequested);
    on<AuthLogoutRequested>(_handleLogoutRequested);
  }

  Future<void> _handleLoginRequested(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(LoginLoading());
      final user = await login(event.email, event.password);
      emit(LoginSuccess(user: user));
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  Future<void> _handleRegisterRequested(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(RegisterLoading());
      await register(
        event.email,
        event.password,
        event.confirmPassword,
        event.name,
        event.kpk,
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(message: e.toString()));
    }
  }
  Future<void> _handleLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _authService.logout();
      emit(AuthInitial());

      Navigator.of(event.context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.login,
            (route) => false, // Hapus semua route
      );
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  Future<UserModel> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> register(
    String email,
    String password,
    String confirmPassword,
    String name,
    String kpk,
  ) async {
    return await _authService.register(
      email,
      password,
      confirmPassword,
      name,
      kpk,
    );
  }
}
