import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:grocerai/features/auth/presentation/cubit/resend_email_timer_cubit.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 64),
              const SizedBox(height: 20),
              const Text(
                "A verification link has been sent to your email.\nPlease verify before continuing.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("I Verified"),
                    onPressed: () {
                      context.read<AuthBloc>().add(CheckEmailVerification());
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<ResendEmailCubit, int>(
                builder: (context, secondsLeft) {
                  return TextButton(
                    onPressed: secondsLeft == 0
                        ? () {
                      context.read<AuthBloc>().add(ResendVerificationEmail());

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Verification email sent again."),
                        ),
                      );

                      context.read<ResendEmailCubit>().startCountdown(60);
                    }
                        : null,
                    child: Text(
                      secondsLeft == 0
                          ? "Resend Verification Email"
                          : "Wait $secondsLeft s",
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
