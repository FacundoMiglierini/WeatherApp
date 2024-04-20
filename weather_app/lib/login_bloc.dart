import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:email_validator/email_validator.dart';
import 'database_controller.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()){

    on<LoginEvent>(_onLogin);

  }

  _onLogin(LoginEvent event, Emitter<LoginState> emit) async {
    if (event is LoginButtonPressed) {
      emit(LoginLoading());

      try {
        var email = event.props[0];
        var password = event.props[1];
        
        if (!EmailValidator.validate(email)) {
          throw const FormatException('Invalid email format');
        }
        
        if (!DatabaseHelper().isValidUser(email, password)) {
          throw Exception('Wrong credentials');
        }

        await Future.delayed(const Duration(seconds: 2));
        emit(LoginSuccess());
      } catch (error) {
        emit(LoginFailure(error: error.toString()));
      }
    }
  } 
}