import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/helper/App_Validator.dart';
import '../../../core/translation/translation_key.dart';
import '../../../core/utils/assets.dart';
import '../../../core/widgets/Cust_Text_btn.dart';
import '../../../core/widgets/Custm_Text_Form_Fild.dart';
import '../../../core/widgets/Custm_btn.dart';
import '../cubit/register_cubit/register_cubit.dart';
import '../cubit/register_cubit/register_state.dart';
import 'login_views.dart';

class RegisterViews extends StatelessWidget {
  const RegisterViews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginViews()),
            );
          }
        },
        builder: (context, state) {
          var cubit = RegisterCubit.get(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: cubit.formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            image: DecorationImage(
                              image: AssetImage(Appassets.flag),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              cubit.setProfileImage(File(pickedFile.path));
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: cubit.profileImage != null
                                ? ClipOval(
                              child: Image.file(
                                cubit.profileImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustmTextFormFild(
                      validator: AppValidator.validatorUserNameOptional,
                      controller: cubit.userName,
                      hintText: 'Username (Optional)',
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    CustmTextFormFild(
                      validator: (String? value) {
                        return AppValidator.validatorPasswordConfirm(
                            value, cubit.password.text);
                      },
                      obscureText: cubit.passwordConfirmSecure,
                      controller: cubit.passwordConfirm,
                      hintText: 'Password confirm',
                      prefixIcon: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(Appassets.passward),
                      ),
                      suffixIcon: IconButton(
                        onPressed: cubit.changePasswordConfirmVisibility,
                        icon: SvgPicture.asset(Appassets.unlock),
                      ),
                      width: 320,
                      height: 55,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 10),
                    state is RegisterLoading
                        ? const CircularProgressIndicator()
                        : CustmBtn(
                      text: TranslationKeys.Register,
                      width: 300,
                      height: 55,
                      fontSize: 18,
                      onPressed: cubit.onRegisterPressed,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        const SizedBox(width: 10),
                        CustomTextBtn(
                          text: 'Login',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginViews()),
                            );
                          },
                        ),
                      ],
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
