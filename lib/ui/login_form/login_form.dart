import 'package:flutter/material.dart';
import 'package:tomza_kit/ui/components/input/form_header.dart';
import 'package:tomza_kit/ui/components/input/tomza_user_input.dart';
import 'package:tomza_kit/ui/components/shake_change.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.header,
    required this.userController,
    required this.passwordController,
    required this.shakeTick,
    this.isLoginLoading = false,
    this.isPasswordVisible = false,
  });

  final String header;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool isLoginLoading;
  final bool isPasswordVisible;
  final int shakeTick;

  @override
  Widget build(BuildContext context) {
    return ShakeOnChange(
      tick: shakeTick,
      child: Column(
        children: [
          FormHeader(title: header),
          UserInput(
            title: '',
            controller: userController,
            label: 'Usuario',
            hint: 'Ingrese su usuario',
            prefixIcon: const Icon(Icons.person),
          ),
          UserInput(
            title: '',
            controller: passwordController,
            label: 'Contraseña',
            hint: 'Ingrese su contraseña',
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
