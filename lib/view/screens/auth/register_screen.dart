import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../transition/fadeTransition.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../../utils/text_util.dart';
import '../../widgets/elegant_components.dart';
import '../../widgets/my_snake_bar.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final HomeController homeController = Get.find<HomeController>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: MyColor.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MyColor.textSecondary.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: MyColor.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Create Account',
                          style: outfitSemiBold.copyWith(
                            fontSize: 24,
                            color: MyColor.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Join Eclipse VPN and protect your privacy',
                      style: outfitRegular.copyWith(
                        fontSize: 16,
                        color: MyColor.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Registration Form
                    ElegantCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          ModernTextField(
                            label: 'Full Name',
                            hintText: 'Enter your full name',
                            controller: nameController,
                            prefixIcon: Icons.person_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            label: 'Email Address',
                            hintText: 'Enter your email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              if (!GetUtils.isEmail(value!)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            label: 'Phone Number',
                            hintText: 'Enter your phone number',
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            label: 'Password',
                            hintText: 'Create a password',
                            controller: passwordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a password';
                              }
                              if (value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ModernTextField(
                            label: 'Confirm Password',
                            hintText: 'Confirm your password',
                            controller: confirmPasswordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    GetBuilder<AuthController>(builder: (authController) {
                      return ModernButton(
                        text: 'Create Account',
                        isLoading: authController.isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            authController
                                .registration(
                              nameController.text,
                              emailController.text,
                              passwordController.text,
                              phoneController.text,
                            )
                                .then((responseModel) {
                              if (responseModel.isSuccess) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                homeController.getUsers();
                                FadeScreenTransition(
                                  screen: const HomeScreen(),
                                ).navigate(context);
                              } else {
                                MySnakeBar.showSnakeBar(
                                  'Sign Up',
                                  responseModel.message ?? '',
                                );
                              }
                            }).catchError((error) {
                              MySnakeBar.showSnakeBar(
                                'Sign Up',
                                'Something went wrong!',
                              );
                              authController.updateError();
                            });
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 20),

                    // Cancel Button
                    ModernButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Google Sign-Up Button
                    GetBuilder<AuthController>(builder: (authController) {
                      return ModernButton(
                        text: 'Sign Up with Google',
                        icon: Icons.account_circle_outlined,
                        isLoading: authController.isLoading,
                        isOutlined: true,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          authController.googleSignIn().then((responseModel) {
                            if (responseModel.isSuccess) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              homeController.getUsers();
                              FadeScreenTransition(
                                screen: const HomeScreen(),
                              ).navigate(context);
                            } else if (responseModel.code == 409) {
                              // Account linking required
                              MySnakeBar.showSnakeBar(
                                'Google Sign Up',
                                'An account with this email already exists. Please sign in with your existing credentials and link your Google account in settings.',
                              );
                            } else {
                              MySnakeBar.showSnakeBar(
                                'Google Sign Up',
                                responseModel.message ?? '',
                              );
                            }
                          }).catchError((error) {
                            MySnakeBar.showSnakeBar(
                              'Google Sign Up',
                              'Something went wrong!',
                            );
                            authController.updateError();
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
