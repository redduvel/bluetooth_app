import 'package:bluetooth_app/bloc/tspl/tspl.event.dart';
import 'package:bluetooth_app/bloc/tspl/tspl.state.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TsplBloc extends Bloc<TsplEvent, TsplState> {
  Product? currentProduct;
  Employee? currentEmployee;
  bool editTemplate = false;
  DateTime selectedTime = DateTime.now();
  DateTime adjustmentTime = DateTime.now();
  String adjustmentType = 'defrosting';

  TsplBloc() : super(LabelInitial()) {
    on<SetCurrentProduct>((event, emit) {
      currentProduct = event.product;
      adjustmentTime = _setAdjustmentTime(adjustmentType);
      _emitSettingsUpdated(emit);
    });

    on<SetCurrentEmployee>((event, emit) {
      currentEmployee = event.employee;
      _emitSettingsUpdated(emit);
    });

    on<SetSelectedTime>((event, emit) {
      selectedTime = event.selectedTime;
      adjustmentTime = _setAdjustmentTime(adjustmentType);
      editTemplate = true;
      _emitSettingsUpdated(emit);
    });

    on<SetTimeAdjustment>((event, emit) {
      adjustmentType = event.adjustmentType;
      adjustmentTime = _setAdjustmentTime(adjustmentType);
      editTemplate = true;
      _emitSettingsUpdated(emit);
    });

    on<GenerateLabel>((event, emit) {
      if (currentProduct == null || currentEmployee == null) return;

      DateTime adjustedTime = _setAdjustmentTime(adjustmentType);

      String labelContent = '''
      ${currentProduct!.subtitle}
      ${selectedTime.toString().substring(0, 16)}
      ${adjustedTime.toString().substring(0, 16)}
      ${currentEmployee!.fullName}
      ''';

      emit(LabelGenerated(labelContent));
    });
  }

  DateTime _setAdjustmentTime(String adjustmentType) {
      switch (adjustmentType) {
        case 'defrosting':
          return selectedTime.add(Duration(hours: currentProduct!.defrosting));
        case 'closedTime':
          return selectedTime.add(Duration(hours: currentProduct!.closedTime));
        case 'openedTime':
          return selectedTime.add(Duration(hours: currentProduct!.openedTime));
        default:
          return selectedTime;
      }
  }

  void _emitSettingsUpdated(Emitter<TsplState> emit) {
    if (currentProduct != null && currentEmployee != null) {
      emit(LabelSettingsUpdated(
        currentProduct: currentProduct!,
        currentEmployee: currentEmployee!,
        selectedTime: selectedTime,
        adjustmentTime: adjustmentTime ?? DateTime.now(),
        adjustmentType: adjustmentType,
      ));
    }
  }
}
