import 'package:bluetooth_app/bloc/bloc.bloc.dart';
import 'package:bluetooth_app/models/employee.dart';
import 'package:bluetooth_app/models/nomenclature.dart';
import 'package:bluetooth_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({super.key});

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GenericBloc<Employee>, GenericState<Employee>>(
        builder: (context, employeeState) =>
            BlocBuilder<GenericBloc<Nomenclature>, GenericState<Nomenclature>>(
                builder: (context, nomenclatureState) =>
                    BlocBuilder<GenericBloc<Product>, GenericState<Product>>(
                      builder: (context, productState) {
                        return CustomScrollView(
                          slivers: [
                            const SliverAppBar(
                              title: Text('Админ панель'),
                            ),
                            if (employeeState is ItemsLoaded<Employee>)
                            SliverList(delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ListTile(
                                  title: Text( employeeState.items[index].fullName),
                                  subtitle: Text(employeeState.items[index].id),
                                );
                              },
                              childCount: employeeState.items.length
                            )),
                            const SliverToBoxAdapter(
                              child: Divider(),
                            ),
                            if (nomenclatureState is ItemsLoaded<Nomenclature>)
                            SliverList(delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ListTile(
                                  title: Text(nomenclatureState.items[index].name),
                                  subtitle: Text(nomenclatureState.items[index].id),
                                );
                              },
                              childCount: nomenclatureState.items.length
                            )),
                            const SliverToBoxAdapter(
                              child: Divider(),
                            ),
                            if (productState is ItemsLoaded<Product>)
                            SliverList(delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ListTile(
                                  title: Text(productState.items[index].title),
                                  subtitle: Column(
                                    children: [
                                      Text(productState.items[index].category.id),
                                      Text(productState.items[index].category.name),
                                    ],
                                  ),
                                );
                              },
                              childCount: productState.items.length
                            ))
                          ],
                        );
                      },
                    )),
      ),
    );
  }
}
