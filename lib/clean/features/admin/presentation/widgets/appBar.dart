import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:flutter/material.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  
  const AdminAppBar({super.key, required this.tabController});

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(120);
}

class _AdminAppBarState extends State<AdminAppBar> {
  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      title: const Text('Панель администратора'),
      bottom: TabBar(
        controller: widget.tabController,
        labelColor: AppColors.greenOnSurface,
        indicatorColor: AppColors.greenOnSurface,
        overlayColor: const WidgetStatePropertyAll(AppColors.greenSurface),
        tabs: const [
          Tab(text: 'Сотрудники', icon: Icon(Icons.person)),
          Tab(text: 'Категории', icon: Icon(Icons.category)),
          Tab(text: 'Продукты', icon: Icon(Icons.egg),),
        ]
      ),
    );
  }
}