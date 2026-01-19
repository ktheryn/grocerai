import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/auth/presentation/auth_screen.dart';
import 'package:grocerai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:grocerai/features/auth/presentation/bloc/login_form_bloc/login_form_bloc.dart';
import 'package:grocerai/features/auth/presentation/cubit/resend_email_timer_cubit.dart';
import 'package:grocerai/features/auth/presentation/splash.dart';
import 'package:grocerai/features/auth/presentation/verification_screen.dart';
import 'package:grocerai/features/home/presentation/home.dart';
import 'package:grocerai/locator.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AppStarted()),
        ),
        BlocProvider<LoginFormBloc>(
          create: (context) => LoginFormBloc(context.read<AuthBloc>()),
        ),
        BlocProvider<ResendEmailCubit>(
          create: (_) => ResendEmailCubit(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/splash',
        routes: {
          '/auth': (context) => AuthScreen(),
          '/home': (context) => const HomeScreen(title: 'GrocerAI',),
          '/splash': (context) => const SplashScreen(),
          '/verification': (context) => const EmailVerificationPage(),
        },
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/home', (route) => false);
              } else if (state is AuthUnauthenticated) {
                navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/auth', (route) => false);
              } else if (state is AuthVerificationState) {
                navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/verification', (route) => false);
              } else if (state is AuthInitial) {
                navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/splash', (route) => false);
              } else {
                navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/splash', (route) => false);
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}
