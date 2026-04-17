import 'package:firetask/modules/auth/providers/auth_provider.dart';
import 'package:firetask/routes/app_routers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/home/home_screen.dart';
import '../modules/home/task_detail_screen.dart';

final routesProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStreamProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;
      final isLoggedIn = authState.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggingIn && isLoggedIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRouters.home,
        builder: (context, state) {
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: AppRouters.register,
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRouters.login,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/taskDetail/:taskId',
        name: AppRouters.taskDetail,
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(id: taskId);
        },
      ),
    ],
  );
});
