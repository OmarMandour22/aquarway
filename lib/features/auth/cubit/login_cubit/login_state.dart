import '../../data/model/user_model.dart';

class LoginState {}

class LoginInitial extends LoginState {}

class LoginChangePasswordVisibility extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModel userModel;
  LoginSuccess({required this.userModel});
}

class LoginError extends LoginState {
  final String error;
  LoginError({required this.error});
}
