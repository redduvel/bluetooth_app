import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_button.dart';
import 'package:bluetooth_app/clean/core/Presentation/widgets/primary_textfield.dart';
import 'package:bluetooth_app/clean/features/admin/presentation/admin_screen.dart';
import 'package:bluetooth_app/pages/home_page.dart';
import 'package:flutter/material.dart';

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
                    toPage: HomePage(),
                    text: 'Войти',
                    onPressed: () {
                      if (nameController.text == "Админ" && passwordController.text == '1234') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                      }
                    },
                    icon: Icons.login),
              )
            ],
          ),
        ));
  }
}
