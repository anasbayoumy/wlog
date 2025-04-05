import 'package:flutter/material.dart';
import 'package:wlog/features/auth/presentation/widgets/auth_field.dart';
import 'package:wlog/features/auth/presentation/widgets/auth_gradientbtn.dart';

import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Form(
        key: formkey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            AuthField(
              hintText: 'Email',
              controller: emailController,
            ),
            const SizedBox(height: 20),
            AuthField(
              hintText: 'Password',
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            AuthGradientbtn(
              text: "Login",
              onPressed: () {},
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account? ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/signup');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()));
                    },
                    child: const Text("SIGN UP")),
              ],
            ),
          ]),
        ),
      ),
    ));
  }
}
