import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/repo/auth_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  /// 🔥 NEW: Category filter state
  String selectedCategory = "all";

  /// 🔁 Navigation
  void changeIndex(int index) {
    currentIndex = index;
    emit(HomeChangeIndex(index: index));
  }

  /// 🔥 Change Category
  void changeCategory(String category) {
    selectedCategory = category;
    emit(HomeChangeIndex(index: currentIndex)); // reuse state
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