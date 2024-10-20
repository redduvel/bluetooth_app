import 'package:bloc/bloc.dart';

class DropdownCubit<T> extends Cubit<T?> {
  DropdownCubit() : super(null);

  late final List<T> _options;

  // Конструктор, принимающий список опций
  DropdownCubit.options({required List<T> options}) : _options = options, super(null);

  // Геттер для получения списка опций
  List<T> get options => List.unmodifiable(_options);

  // Метод для выбора опции
  void selectOption(T? value) {
    emit(value);
  }

  // Метод для удаления выбранной опции
  void removeSelectedOption() {
    if (state != null && _options.contains(state)) {
      _options.remove(state);
      emit(null); // Сбрасываем выбранное значение после удаления
    }
  }
}
