import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/repo/auth_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  /// 🔁 Navigation
  void changeIndex(int index) {
    currentIndex = index;
    emit(HomeChangeIndex(index: index));
  }

  /// 🚪 Logout
  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await AuthRepo().logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(error: e.toString()));
    }
  }
}