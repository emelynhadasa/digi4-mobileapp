part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String kpk;

  AuthRegisterEvent({
    required this.name,
    required this.password,
    required this.email,
    required this.confirmPassword,
    required this.kpk,
  });
}

class AuthLogoutRequested extends AuthEvent {
  final String message;

  AuthLogoutRequested({this.message = "Logout"});
}
