import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Domain/bloc/db.bloc.dart';
import 'package:bluetooth_app/clean/core/Domain/entities/user.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';

class UserListTile extends StatefulWidget {
  final User user;
  final DBBloc<User> bloc;

  const UserListTile({super.key, required this.user, required this.bloc});

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(widget.user),
      leading: const Icon(Icons.person),
      title: Text(widget.user.fullName),
      trailing: PopupMenuButton(
        color: AppColors.white,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showEditCategoryDialog(widget.user);
              break;
            case 'delete':
              _showDeleteConfirmationDialog(widget.user);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Изменить'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Удаление сотрудника'),
          content: const Text('Вы действительно хотите удалить сотрудника?'),
          actions: [
            PrimaryButtonIcon(
              text: 'Отмена',
              icon: Icons.close,
              type: ButtonType.normal,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            PrimaryButtonIcon(
              onPressed: () {
                widget.bloc.add(DeleteItem<User>(user.id));
                Navigator.pop(context);
              },
              text: 'Удалить',
              type: ButtonType.delete,
              icon: Icons.delete,
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(User user) {
    editController.text = user.fullName;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryTextField(
                  controller: editController,
                  hintText: user.fullName,
                  width: 500,
                ),
                const SizedBox(height: 20),
                PrimaryButtonIcon(
                  text: 'Сохранить изменения',
                  icon: Icons.save,
                  selected: true,
                  width: 500,
                  onPressed: () {
                    widget.bloc.add(UpdateItem<User>(
                      user.copyWith(id: user.id, fullName: editController.text),
                    ));
                    editController.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
