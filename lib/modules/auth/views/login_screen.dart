// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firetask/common/app_button.dart';
import 'package:firetask/common/app_input_decoration.dart';
import 'package:firetask/common/app_snackbars.dart';
import 'package:firetask/modules/auth/model/auth_state.dart';
import 'package:firetask/modules/auth/providers/auth_provider.dart';
import 'package:firetask/routes/app_routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final stateObsecureProvider = StateProvider((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.action == AuthAction.login) {
        next.status.whenOrNull(
          data: (data) {
            AppSnackbars.showSuccess(context, 'Login Successful');
            context.go('/');
          },
          error: (error, stackTrace) {
            AppSnackbars.showError(
              context,
              handleAuthError(error as FirebaseAuthException),
            );
          },
        );
      }
    });
    final state = ref.watch(authProvider);
    final isObscure = ref.watch(stateObsecureProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Secure Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome Back', style: TextStyle(fontSize: 28)),
              SizedBox(height: 20),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUnfocus,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppInputDecoration.input(
                  context: context,
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value);

                  if (!emailValid) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUnfocus,
                obscureText: isObscure,
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: AppInputDecoration.input(
                  context: context,
                  label: 'Password',
                  icon: Icons.lock,
                  suffix: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      ref.read(stateObsecureProvider.notifier).state =
                          !isObscure;
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              AppButton(
                text: 'Login',
                textColor: Colors.white,
                isLoading: state.status.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(authProvider.notifier)
                        .login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                  }
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dont't have an account, "),
                  InkWell(
                    onTap: () => context.pushNamed(AppRouters.register),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
