import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/repo/auth_repo.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  var currentPassword = TextEditingController();
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();

  var formKey = GlobalKey<FormState>();

  bool currentPasswordSecure = true;
  bool newPasswordSecure = true;
  bool confirmPasswordSecure = true;

  static ChangePasswordCubit get(context) => BlocProvider.of(context);

  void changeCurrentPasswordVisibility() {
    currentPasswordSecure = !currentPasswordSecure;
    emit(ChangePasswordPasswordVisibility());
  }

  void changeNewPasswordVisibility() {
    newPasswordSecure = !newPasswordSecure;
    emit(ChangePasswordPasswordVisibility());
  }

  void changeConfirmPasswordVisibility() {
    confirmPasswordSecure = !confirmPasswordSecure;
    emit(ChangePasswordPasswordVisibility());
  }

  void changePassword() async {
    if (!formKey.currentState!.validate()) return;

    emit(ChangePasswordLoading());

    AuthRepo repo = AuthRepo();

    var result = await repo.changePassword(
      currentPassword: currentPassword.text,
      newPassword: newPassword.text,
    );

    result.fold(
          (error) => emit(ChangePasswordError(error: error)),
          (_) => emit(ChangePasswordSuccess()),
    );
  }
}