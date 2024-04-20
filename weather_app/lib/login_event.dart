part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<String> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginButtonPressed({required this.email, required this.password});

  @override
  List<String> get props => [email, password];

  @override
  String toString() => 'LoginButtonPressed { email: $email, password: $password }';
}