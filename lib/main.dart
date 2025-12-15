// ==================== main.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'core/network/api_client.dart';
import 'core/utils/constants.dart';

// Auth imports
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';

// Task imports
import 'features/tasks/data/datasources/task_remote_datasource.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/create_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'features/tasks/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();
  final apiClient = ApiClient(client: httpClient);

  // Auth dependencies
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
    apiClient: apiClient,
  );

  // Task dependencies
  final taskRemoteDataSource = TaskRemoteDataSourceImpl(apiClient);
  final taskRepository = TaskRepositoryImpl(taskRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
            authRepository: authRepository,
          )..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            getTasksUseCase: GetTasksUseCase(taskRepository),
            createTaskUseCase: CreateTaskUseCase(taskRepository),
            deleteTaskUseCase: DeleteTaskUseCase(taskRepository),
            taskRepository: taskRepository,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return authProvider.isAuthenticated
              ? const HomePage()
              : const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
