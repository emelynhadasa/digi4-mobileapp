part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class LoginLoading extends AuthState {
  final String message;

  LoginLoading({this.message = "Loading..."});
}

class LoginSuccess extends AuthState {
  final String message;
  final UserModel user;

  LoginSuccess({this.message = "Login Successful", required this.user});
}

class LoginFailure extends AuthState {
  final String message;

  LoginFailure({this.message = "Login Failed"});
}

class RegisterSuccess extends AuthState {
  final String message;

  RegisterSuccess({this.message = "Registration Successful"});
}

class RegisterFailure extends AuthState {
  final String message;

  RegisterFailure({this.message = "Registration Failed"});
}

class RegisterLoading extends AuthState {
  final String message;

  RegisterLoading({this.message = "Loading..."});
}
