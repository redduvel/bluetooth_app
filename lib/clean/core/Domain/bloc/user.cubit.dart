import 'package:flutter_bloc/flutter_bloc.dart';
enum CurrentUser {
  admin,
  employee
}

class UserCubit extends Cubit<CurrentUser> {
  UserCubit() : super(CurrentUser.employee);

  static UserCubit? _instance;

  factory UserCubit.instance() {
    _instance ??= UserCubit();
    return _instance!;
  }

  static CurrentUser get current => _instance?.state ?? CurrentUser.admin;

  void setUser(CurrentUser user) => emit(user);
}