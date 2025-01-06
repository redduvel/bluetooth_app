import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking_db/marking.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/other/data_row.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    context.read<DBBloc<Marking>>().add(LoadItems());
    super.initState();
  }

  void _sort<T>(
    List<Marking> source,
    Comparable<T> Function(Marking d) getField,
    int columnIndex,
    bool ascending,
  ) {
    source.sort((a, b) => a.product.title.compareTo(b.product.title));
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
          child: BlocBuilder<DBBloc<Marking>, DBState<Marking>>(
            builder: (context, state) {
              if (state is ItemsLoaded<Marking>) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: DataTable2(
                          empty: const Text('Здесь будут отображаться маркировки', style: AppTextStyles.bodyMedium16,),
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          minWidth: 700,
                          columnSpacing: 0,
                          
                          decoration: BoxDecoration(
                            
                              borderRadius: BorderRadius.circular(50)),
                          
                          columns: [
                            DataColumn(
                              
                                label: const Text('Название', style: AppTextStyles.bodyMedium16,),
                                onSort: (columnIndex, ascending) => _sort(
                                    state.items,
                                    (m) => m.product.title,
                                    columnIndex,
                                    ascending)),
                            const DataColumn(label: Text('Статус', style: AppTextStyles.bodyMedium16,)),
                            const DataColumn(label: Text('Осталось времени', style: AppTextStyles.bodyMedium16,)),
                            const DataColumn(label: Text('Распечатано', style: AppTextStyles.bodyMedium16,)),
                          ],
                          rows:
                              state.items.map((m) => createDataRow(m)).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const Center(
                child: CupertinoActivityIndicator(color: AppColors.primary,),
              );
            },
          ),
        ),
      ),
    );
  }
}
