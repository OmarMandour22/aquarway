import 'package:aquarway/features/user/cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/data/repo/auth_repo.dart';
import '../../auth/data/model/user_model.dart';

class UserCubit extends Cubit<UserState> {
  final AuthRepo repo;

  UserCubit(this.repo) : super(UserInitial());

  List<UserModel> users = [];

  Future<void> searchUsers(String query) async {
    emit(UserLoading());

    final result = await repo.searchUsers(query);

    users = result;
    emit(UserLoaded(result));
  }
}