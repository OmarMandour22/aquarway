import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/auth_repo.dart';
import '../../data/model/user_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // Controllers
  var userName = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var passwordConfirm = TextEditingController();
  var formKey = GlobalKey<FormState>();

  // Password visibility
  bool passwordSecure = true;
  bool passwordConfirmSecure = true;

  // Profile image
  File? profileImage;

  static RegisterCubit get(context) => BlocProvider.of(context);

  // Toggle password visibility
  void changePasswordVisibility() {
    passwordSecure = !passwordSecure;
    emit(RegisterChangePasswordVisibility());
  }

  void changePasswordConfirmVisibility() {
    passwordConfirmSecure = !passwordConfirmSecure;
    emit(RegisterChangePasswordVisibility());
  }

  // Set profile image
  void setProfileImage(File image) {
    profileImage = image;
    emit(ProfileImageChanged());
  }

  // Register user
  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;

    emit(RegisterLoading());

    try {
      AuthRepo repo = AuthRepo();
      var response = await repo.register(
        username: userName.text.isEmpty ? null : userName.text,
        email: email.text,
        password: password.text,
        image: profileImage,
      );

      response.fold(
            (error) => emit(RegisterError(error: error)),
            (userData) => emit(RegisterSuccess(userModel: userData)),
      );
    } catch (e) {
      emit(RegisterError(error: e.toString()));
    }
  }
}
