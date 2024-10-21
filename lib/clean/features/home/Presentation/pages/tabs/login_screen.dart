import 'package:bluetooth_app/clean/config/theme/colors.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.bloc.dart';
import 'package:bluetooth_app/clean/core/Presentation/bloc/navigation_bloc/navigation.event.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/admin_screen.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/pages/main_screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController= TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PrimaryTextField(controller: nameController, width: 500, hintText: 'Имя пользователя',),
              PrimaryTextField(controller: passwordController, width: 500, hintText: 'Пароль',),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PrimaryButtonIcon(
                    width: 500,
                    text: 'Войти',
                    onPressed: () {
                      if (nameController.text == "1" && passwordController.text == '1') {
                        context.read<NavigationBloc>().add(NavigateTo(CategoryScreen()));
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
                      }
                    },
                    icon: Icons.login),
              )
            ],
          ),
        ));
  }
}
