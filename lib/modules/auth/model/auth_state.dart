import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthAction { login, register, logout, none }

class AuthState {
  final AsyncValue<void> status;
  final AuthAction action;
  AuthState({required this.status, this.action = AuthAction.none});
}
