import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme_pallet.dart';
import 'package:wlog/features/auth/presentation/widgets/auth_field.dart';
import 'package:wlog/features/auth/presentation/widgets/auth_gradientbtn.dart';

import 'loginpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppPallete.backgroundColor,
          title: const Text(''),
          centerTitle: true,
        ),
        body: Center(
          child: Form(
            key: formkey,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 50),
                    AuthField(
                      hintText: 'Full Name',
                      controller: emailController,
                      // isPassword: false,
                    ),
                    const SizedBox(height: 20),
                    AuthField(
                      hintText: 'Email',
                      controller: emailController,
                      // isPassword: false,
                    ),
                    const SizedBox(height: 20),
                    AuthField(
                      hintText: 'Password',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    const AuthGradientbtn(text: "Sign Up"),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                            child: const Text("LOGIN")),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
