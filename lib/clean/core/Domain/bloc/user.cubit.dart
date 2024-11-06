import 'package:flutter_bloc/flutter_bloc.dart';

enum CurrentUser {
  admin,
  employee
}

class UserCubit extends Cubit<CurrentUser> {
  UserCubit() : super(CurrentUser.employee);
  
  void setUser(CurrentUser user) => emit(user);
}