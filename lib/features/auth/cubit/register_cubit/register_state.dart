import '../../data/model/user_model.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterChangePasswordVisibility extends RegisterState {}

class ProfileImageChanged extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserModel userModel;
  RegisterSuccess({required this.userModel});
}

class RegisterError extends RegisterState {
  final String error;
  RegisterError({required this.error});
}
