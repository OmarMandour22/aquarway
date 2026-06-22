import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/auth_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  var userName = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var formKey = GlobalKey<FormState>();

  bool passwordSecure = true;

  static LoginCubit get(context) => BlocProvider.of(context);

  void changePasswordVisibility() {
    passwordSecure = !passwordSecure;
    emit(LoginChangePasswordVisibility());
  }

  void login() async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());

    AuthRepo repo = AuthRepo();
    var loginResponse = await repo.login(email: email.text, password: password.text);

    loginResponse.fold(
          (error) => emit(LoginError(error: error)),
          (userModel) => emit(LoginSuccess(userModel: userModel)),
    );
  }



  void resetPassword() async {
    if (email.text.isEmpty) return;

    emit(ResetPasswordLoading());

    final result = await AuthRepo().resetPassword(
      email: email.text.trim(),
    );

    result.fold(
          (error) => emit(
        ResetPasswordError(error: error),
      ),
          (_) => emit(
        ResetPasswordSuccess(),
      ),
    );
  }

}
