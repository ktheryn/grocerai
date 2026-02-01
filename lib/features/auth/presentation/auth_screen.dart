import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:grocerai/core/constants.dart';
import 'package:grocerai/features/auth/presentation/bloc/login_form_bloc/login_form_bloc.dart';
import 'package:grocerai/features/auth/presentation/widgets/authmode_switcher.dart';
import 'package:grocerai/features/auth/presentation/widgets/custom_box_button.dart';
import 'package:grocerai/features/auth/presentation/widgets/custom_textformfield.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      builder: (context, state) {
        final authBloc = context.read<LoginFormBloc>();
        final isLogin = state.authMode == AuthMode.login;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // App Logo & Brand Name
                      Image.asset('assets/images/grocer_ai_logo_without_bg.png', height: 200,), // Ensure you have your logo
                      const SizedBox(height: 10),
                      Text(
                        isLogin ? "Welcome Back" : "Create Account",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C4E5B),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Fields
                      if (!isLogin) ...[
                        userNameTextFormField(state),
                        const SizedBox(height: 15),
                      ],
                      emailTextFormField(state),
                      const SizedBox(height: 15),
                      passwordTextFormField(state, authBloc),

                      if (!isLogin) ...[
                        const SizedBox(height: 10),
                        _buildPasswordRequirements(state.password.value),
                      ],

                      const SizedBox(height: 10),
                      errorAuthText(state),

                      const SizedBox(height: 15),
                      signButton(authBloc),

                      const SizedBox(height: 25),
                      AuthModeSwitcherText(
                        promptText: isLogin ? "Don't have an account?" : "Already have an account?",
                        actionText: isLogin ? 'Sign Up' : 'Sign In',
                        onTap: () {
                          final newMode = isLogin ? AuthMode.register : AuthMode.login;
                          authBloc.add(SwitchAuthMode(authMode: newMode));
                        },
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // UPDATED: Styling for TextFields to match the soft-white rounded look
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hintColor),
      fillColor: Colors.white,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
    );
  }

  Widget emailTextFormField(LoginFormState state) =>
      CustomTextFormField(controller: emailController, decoration: _inputDecoration('Email'),);

  Widget userNameTextFormField(LoginFormState state) =>
      CustomTextFormField(controller: userNameController, decoration: _inputDecoration('Full Name'));

  Widget passwordTextFormField(LoginFormState state, LoginFormBloc authBloc) {
    return CustomTextFormField(
      controller: passwordController,
      obscureText: !state.showPassword,
      onChanged: (value) => authBloc.add(SignInPasswordChanged(password: value)),
      decoration: _inputDecoration('Password').copyWith(
        suffixIcon: IconButton(
          onPressed: () => authBloc.add(PasswordShow()),
          icon: Icon(
            !state.showPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.hintColor,
          ),
        ),
      ),
    );
  }

  Widget signButton(LoginFormBloc authBloc) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, AppColors.accentGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: CustomButton(
        onTap: () {
          authBloc.state.authMode == AuthMode.login
              ? authBloc.add(SignIn(email: emailController.text, password: passwordController.text))
              : authBloc.add(SignUp(email: emailController.text, password: passwordController.text, userName: userNameController.text));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            authBloc.state.authMode == AuthMode.login ? 'Sign In' : 'Sign Up',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget errorAuthText(LoginFormState state) {
    return Text(
      state.status == FormzSubmissionStatus.failure ? state.authError : '',
      style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
    );
  }

  Widget _buildPasswordRequirements(String password) {
    bool hasEightChars = password.length >= 8;
    bool hasNumber = password.contains(RegExp(r'\d'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requirementRow("At least 8 characters", hasEightChars),
        const SizedBox(height: 4),
        _requirementRow("At least one number", hasNumber),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _requirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: isMet ? AppColors.primaryGreen : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppColors.primaryGreen : Colors.grey.shade600,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}