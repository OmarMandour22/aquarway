import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/helper/App_Validator.dart';
import '../../../core/helper/App_pop_up.dart';
import '../../../core/translation/translation_key.dart';
import '../../../core/utils/assets.dart';
import '../../../core/widgets/Cust_Text_btn.dart';
import '../../../core/widgets/Custm_Text_Form_Fild.dart';
import '../../../core/widgets/Custm_btn.dart';
import '../../home/views/home_views.dart';
import '../cubit/login_cubit/login_cubit.dart';
import '../cubit/login_cubit/login_state.dart';
import 'Register_views.dart';

class LoginViews extends StatefulWidget {
  const LoginViews({super.key});

  @override
  State<LoginViews> createState() => _LoginViewsState();
}

class _LoginViewsState extends State<LoginViews> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeViews(userModel: state.userModel,)),
            );
          } else if (state is LoginError) {
            AppPopUp.showSnackBar(state.error, context);
          }
        },
        builder: (context, state) {
          var cubit = LoginCubit.get(context);

          return Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: cubit.formKey,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustmTextFormFild(
                            validator: AppValidator.validatorEmail,
                            controller: cubit.email,
                            hintText: 'Email',
                            obscureText: false,
                            prefixIcon: IconButton(
                              onPressed: null,
                              icon: SvgPicture.asset(Appassets.profile),
                            ),
                            suffixIcon: null,
                            width: 320,
                            height: 55,
                            fontSize: 14,
                          ),

                          const SizedBox(height: 12),

                          CustmTextFormFild(
                            validator: AppValidator.validatorPassword,
                            controller: cubit.password,
                            hintText: 'Password',
                            obscureText: cubit.passwordSecure,
                            prefixIcon: IconButton(
                              onPressed: null,
                              icon: SvgPicture.asset(Appassets.passward),
                            ),
                            suffixIcon: IconButton(
                              onPressed: cubit.changePasswordVisibility,
                              icon: SvgPicture.asset(Appassets.unlock),
                            ),
                            width: 320,
                            height: 55,
                            fontSize: 14,
                          ),

                          const SizedBox(height: 20),

                          state is LoginLoading
                              ? const CircularProgressIndicator()
                              : CustmBtn(
                            text: TranslationKeys.Loging,
                            width: 300,
                            height: 55,
                            fontSize: 18,
                            onPressed: cubit.login,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Do not have an account?'),
                              const SizedBox(width: 8),
                              CustomTextBtn(
                                text: 'Register',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterViews(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
