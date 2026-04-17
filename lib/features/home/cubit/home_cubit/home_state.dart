abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeChangeIndex extends HomeState {
  final int index;

  HomeChangeIndex({required this.index});
}

class LogoutLoading extends HomeState {}

class LogoutSuccess extends HomeState {}

class LogoutError extends HomeState {
  final String error;

  LogoutError({required this.error});
}