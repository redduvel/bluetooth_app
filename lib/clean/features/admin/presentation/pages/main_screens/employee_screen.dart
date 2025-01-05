import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/config/theme/text_styles.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/marking/user.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/widgets/user_listtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  late DBBloc<User> bloc;
  late TextEditingController nameController;

  @override
  void initState() {
    bloc = context.read<DBBloc<User>>()..add(LoadItems<User>());
    nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<DBBloc<User>, DBState<User>>(
            bloc: bloc,
            builder: (context, state) {
              if (state is ItemsLoaded<User>) {
                return _buildUsers(state.items);
              }

              if (state is ItemsLoading<User>) {
                return _buildUsers([]);
              }

              if (state is ItemOperationFailed<User>) {
                return _buildError(state.error);
              }

              return const SizedBox.shrink();
            }));
  }

  Widget _buildUsers(List<User> users) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.white,
          title: Text(
            'Управление сотрудниками',
            style: AppTextStyles.labelMedium18.copyWith(fontSize: 24),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            if (Platform.isMacOS || Platform.isWindows)
              PrimaryButtonIcon(
                text: 'Синхронизировать',
                icon: Icons.sync,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                selected: true,
                onPressed: () => bloc.add(Sync<User>()),
              ),
            if (Platform.isAndroid || Platform.isIOS)
              IconButton(
                  onPressed: () => bloc.add(Sync<User>()),
                  icon: const Icon(Icons.sync))
          ],
        ),
        SliverToBoxAdapter(
          child: PrimaryTextField(
              controller: nameController,
              width: double.infinity,
              hintText: 'Полное имя'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverToBoxAdapter(
            child: PrimaryButtonIcon(
              selected: true,
              text: 'Добавить',
              icon: Icons.add,
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Необходимо заполнить все поля'))
                  );
                  return;
                }

                bloc.add(AddItem(User(fullName: nameController.text)));
              },
            ),
          ),
        ),
        if (users.isNotEmpty)
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return UserListTile(
              user: users[index],
              bloc: bloc,
            );
          }, childCount: users.length)),
        if (users.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 15),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.greenOnSurface,
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text('Ошибка загрузки данных: $error'),
    );
  }
}
