// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wlog/core/theme/theme.dart';
// import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';

// import 'package:wlog/features/auth/presentation/widgets/auth_gradientbtn.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Sign up successful! Please check your email.'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             Navigator.pushReplacementNamed(context, '/login');
//           } else if (state is AuthFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             return SafeArea(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 50),
//                         Text(
//                           'Sign Up',
//                           style: Theme.of(context).textTheme.headlineLarge,
//                         ),
//                         const SizedBox(height: 30),
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: const InputDecoration(
//                             labelText: 'Email',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!value.contains('@')) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _passwordController,
//                           decoration: const InputDecoration(
//                             labelText: 'Password',
//                             border: OutlineInputBorder(),
//                           ),
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your password';
//                             }
//                             if (value.length < 6) {
//                               return 'Password must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Full Name',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _usernameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Username (optional)',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value != null && value.isNotEmpty) {
//                               if (value.length < 3) {
//                                 return 'Username must be at least 3 characters';
//                               }
//                               if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
//                                 return 'Username can only contain letters, numbers, and underscores';
//                               }
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 30),
//                         AuthGradientbtn(
//                           text: state is AuthLoading
//                               ? 'Signing up...'
//                               : 'Sign Up',
//                           onPressed: state is AuthLoading
//                               ? null
//                               : () {
//                                   if (_formKey.currentState!.validate()) {
//                                     context.read<AuthBloc>().add(
//                                           SignUpEvent(
//                                             email: _emailController.text,
//                                             password: _passwordController.text,
//                                             name: _nameController.text,
//                                             username:
//                                                 _usernameController.text.isEmpty
//                                                     ? null
//                                                     : _usernameController.text,
//                                           ),
//                                         );
//                                   }
//                                 },
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text('Already have an account?'),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pushReplacementNamed(
//                                     context, '/login');
//                               },
//                               child: const Text('Login'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/theme/theme_pallet.dart';
import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppPallete.backgroundColor,
          title: const Text(''),
          centerTitle: true,
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Sign up successful! Please check your email for verification.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Center(
            child: Form(
              key: formkey,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 50),
                      AuthField(
                        hintText: 'Full Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 20),
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
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return AuthGradientbtn(
                            text: state is AuthLoading
                                ? "Signing Up..."
                                : "Sign Up",
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (formkey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                            SignUpEvent(
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text
                                                  .trim(),
                                              name: nameController.text.trim(),
                                            ),
                                          );
                                    }
                                  },
                          );
                        },
                      ),
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
                                        builder: (context) =>
                                            const LoginPage()));
                              },
                              child: const Text("LOGIN")),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }
}
