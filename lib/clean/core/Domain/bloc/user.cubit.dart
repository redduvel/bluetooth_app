import 'package:flutter_bloc/flutter_bloc.dart';
enum CurrentUser {
  admin,
  employee
}

class UserCubit extends Cubit<CurrentUser> {
  UserCubit._internal() : super(CurrentUser.employee);

  static final UserCubit _instance = UserCubit._internal();

  factory UserCubit() {
    return _instance;
  }

  static CurrentUser get current => _instance.state;

  void setUser(CurrentUser user) => emit(user);
}
