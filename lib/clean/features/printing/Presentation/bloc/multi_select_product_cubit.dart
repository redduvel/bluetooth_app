import 'package:bloc/bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template.dart';
import 'package:equatable/equatable.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/characteristic.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/product.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/template_entry.dart';

// State
class MultiProductState extends Equatable {
  final List<Product> selectedProducts;
  final Map<Product, Characteristic?> selectedCharacteristics;
  final Map<Product, int> productQuantities;

  const MultiProductState({
    this.selectedProducts = const [],
    this.selectedCharacteristics = const {},
    this.productQuantities = const {},
  });

  MultiProductState copyWith({
    Template? editTemplate,
    List<Product>? selectedProducts,
    Map<Product, Characteristic?>? selectedCharacteristics,
    Map<Product, int>? productQuantities,
  }) {
    return MultiProductState(
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedCharacteristics:
          selectedCharacteristics ?? this.selectedCharacteristics,
      productQuantities: productQuantities ?? this.productQuantities,
    );
  }

  List<TemplateEntry> toEntries() {
    return selectedProducts.map((p) {
      return TemplateEntry(
          p, selectedCharacteristics[p], productQuantities[p] ?? 1);
    }).toList();
  }

  @override
  List<Object?> get props =>
      [selectedProducts, selectedCharacteristics, productQuantities];
}

// Cubit
class MultiProductCubit extends Cubit<MultiProductState> {
  MultiProductCubit() : super(const MultiProductState());

  void clear() {
    emit(const MultiProductState());
  }

  // void setEdit(Template template) =>
  //     emit(state.copyWith(editTemplate: template));

  // void edit({String? name, List<TemplateEntry>? products}) {
  //   if (state.editTemplate != null) {
  //     Template editTemplate = state.editTemplate!.copyWith(title: name, listProducts: products);

  //     emit(state.copyWith(
  //         editTemplate: editTemplate));
  //   } else {
  //     print("EDIT null state.editTemplate");
  //   }
  // }

  void fromTemplateEntries(List<TemplateEntry> entries) {
    final selectedProducts = entries.map((entry) => entry.product).toList();

    final selectedCharacteristics = {
      for (var entry in entries) entry.product: entry.characteristic,
    };

    final productQuantities = {
      for (var entry in entries) entry.product: entry.count,
    };

    final state = MultiProductState(
      selectedProducts: selectedProducts,
      selectedCharacteristics: selectedCharacteristics,
      productQuantities: productQuantities,
    );

    emit(state);
  }

  void addProduct(Product product) {
    emit(state.copyWith(
      selectedProducts: [...state.selectedProducts, product],
      selectedCharacteristics: {
        ...state.selectedCharacteristics,
        product: null
      },
      productQuantities: {...state.productQuantities, product: 1},
    ));
  }

  void updateCharacteristic(Product product, Characteristic? characteristic) {
    emit(state.copyWith(
      selectedCharacteristics: {
        ...state.selectedCharacteristics,
        product: characteristic
      },
    ));
  }

  void updateQuantity(Product product, int quantity) {
    emit(state.copyWith(
      productQuantities: {...state.productQuantities, product: quantity},
    ));
  }

  void removeProduct(Product product) {
    final updatedProducts = [...state.selectedProducts]..remove(product);
    final updatedCharacteristics = {...state.selectedCharacteristics};
    final updatedQuantities = {...state.productQuantities};

    updatedCharacteristics.remove(product);
    updatedQuantities.remove(product);

    emit(state.copyWith(
      selectedProducts: updatedProducts,
      selectedCharacteristics: updatedCharacteristics,
      productQuantities: updatedQuantities,
    ));
  }
}
