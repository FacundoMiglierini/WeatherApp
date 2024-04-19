import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:email_validator/email_validator.dart';
import 'database_controller.dart';
import 'package:crypt/crypt.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  Stream<LoginState> mapEventToState(LoginEvent event) async* {

    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        var email = event.props[0];
        var password = event.props[1];
        
        if (!EmailValidator.validate(email)) {
          throw const FormatException('Invalid email format');
        }
        
        DatabaseHelper().user(email, Crypt.sha256(password).toString());

        //await Future.delayed(const Duration(seconds: 2));
        yield LoginSuccess();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}