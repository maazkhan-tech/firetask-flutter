// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firetask/common/app_button.dart';
import 'package:firetask/common/app_input_decoration.dart';
import 'package:firetask/common/app_snackbars.dart';
import 'package:firetask/modules/auth/model/auth_state.dart';
import 'package:firetask/modules/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => true);

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.action == AuthAction.register) {
        next.status.whenOrNull(
          data: (data) {
            AppSnackbars.showSuccess(context, 'Register Successful');
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
    final theme = Theme.of(context);
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fill in the details below to get started",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  decoration: AppInputDecoration.input(
                    context: context,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppInputDecoration.input(
                    context: context,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: ref.watch(passwordVisibilityProvider),
                  decoration: AppInputDecoration.input(
                    context: context,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        ref.watch(passwordVisibilityProvider)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () =>
                          ref.read(passwordVisibilityProvider.notifier).state =
                              !ref.read(passwordVisibilityProvider),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  obscureText: ref.watch(confirmPasswordVisibilityProvider),
                  decoration: AppInputDecoration.input(
                    context: context,
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                    suffix: IconButton(
                      icon: Icon(
                        ref.watch(confirmPasswordVisibilityProvider)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () =>
                          ref
                              .read(confirmPasswordVisibilityProvider.notifier)
                              .state = !ref.read(
                            confirmPasswordVisibilityProvider,
                          ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: AppButton(
                    text: 'Register',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref
                            .read(authProvider.notifier)
                            .register(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _usernameController.text.trim(),
                            );
                      }
                    },
                    textColor: Colors.white,
                    isLoading: state.status.isLoading,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
