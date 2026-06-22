import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/App_Validator.dart';
import '../../../core/helper/App_pop_up.dart';
import '../../../core/widgets/Custm_Text_Form_Fild.dart';
import '../../../core/widgets/Custm_btn.dart';
import '../cubit/login_cubit/login_cubit.dart';
import '../cubit/login_cubit/login_state.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            AppPopUp.showSnackBar(
              "Password reset link sent to your email",
              context,
            );

            Navigator.pop(context);
          }

          if (state is ResetPasswordError) {
            AppPopUp.showSnackBar(
              state.error,
              context,
            );
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text("Forgot Password"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustmTextFormFild(
                      controller: emailController,
                      validator: AppValidator.validatorEmail,
                      hintText: "Email",
                      obscureText: false,
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: null,
                      width: double.infinity,
                      height: 55,
                      fontSize: 14,
                    ),

                    const SizedBox(height: 20),

                    state is ResetPasswordLoading
                        ? const CircularProgressIndicator()
                        : CustmBtn(
                      text: "Send Reset Link",
                      width: double.infinity,
                      height: 55,
                      fontSize: 18,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        cubit.email.text =
                            emailController.text.trim();

                        cubit.resetPassword();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}