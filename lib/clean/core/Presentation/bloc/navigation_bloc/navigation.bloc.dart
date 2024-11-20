import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  dynamic currentPage;

  NavigationBloc(super.initialState) {
    on<NavigateTo>((event, emit) {
      currentPage = event.screen;

      emit(ScreenState(event.screen));
    });

    on<Started>((event, emit) {
      currentPage = null;
      emit(InitialState(event.screen));
    });
  }
}
