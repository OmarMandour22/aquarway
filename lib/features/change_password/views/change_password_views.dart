import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helper/App_Validator.dart';
import '../../../core/widgets/Custm_Text_Form_Fild.dart';
import '../../../core/widgets/Custm_btn.dart';
import '../cubit/change_password_cubit/change_password_cubit.dart';
import '../cubit/change_password_cubit/change_password_state.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password changed successfully")),
            );
            Navigator.pop(context);
          }

          if (state is ChangePasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          var cubit = ChangePasswordCubit.get(context);

          return Scaffold(
            appBar: AppBar(title: const Text("Change Password")),
            body: Form(
              key: cubit.formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CustmTextFormFild(
                      controller: cubit.currentPassword,
                      hintText: "Current Password",
                      obscureText: cubit.currentPasswordSecure,
                      validator: AppValidator.validatorPassword,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: cubit.changeCurrentPasswordVisibility,
                        icon: const Icon(Icons.remove_red_eye),
                      ),
                      width: double.infinity,
                      height: 55,
                      fontSize: 14,
                    ),

                    const SizedBox(height: 12),

                    CustmTextFormFild(
                      controller: cubit.newPassword,
                      hintText: "New Password",
                      obscureText: cubit.newPasswordSecure,
                      validator: AppValidator.validatorPassword,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: cubit.changeNewPasswordVisibility,
                        icon: const Icon(Icons.remove_red_eye),
                      ),
                      width: double.infinity,
                      height: 55,
                      fontSize: 14,
                    ),

                    const SizedBox(height: 12),

                    CustmTextFormFild(
                      controller: cubit.confirmPassword,
                      hintText: "Confirm Password",
                      obscureText: cubit.confirmPasswordSecure,
                      validator: (value) {
                        if (value != cubit.newPassword.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: cubit.changeConfirmPasswordVisibility,
                        icon: const Icon(Icons.remove_red_eye),
                      ),
                      width: double.infinity,
                      height: 55,
                      fontSize: 14,
                    ),

                    const SizedBox(height: 20),

                    state is ChangePasswordLoading
                        ? const CircularProgressIndicator()
                        : CustmBtn(
                      text: "Change Password",
                      width: double.infinity,
                      height: 55,
                      fontSize: 18,
                      onPressed: cubit.changePassword,
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