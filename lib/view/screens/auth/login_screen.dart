import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../transition/fadeTransition.dart';
import '../../../transition/right_to_left.dart';
import '../../../utils/app_layout.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../../utils/text_util.dart';
import '../../widgets/elegant_components.dart';
import '../../widgets/my_snake_bar.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'reset_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController authController = Get.find<AuthController>();
  HomeController homeController = Get.find<HomeController>();

  final TextEditingController emailController = TextEditingController();
  final FocusNode focusEmail = FocusNode();
  final FocusNode focusPass = FocusNode();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    //AppLayout.screenPortrait(colors: MyColor.settingsHeader);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLayout.screenPortrait();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Welcome Header
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: MyColor.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: MyColor.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        style: outfitSemiBold.copyWith(
                          fontSize: 28,
                          color: MyColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your secure connection',
                        style: outfitRegular.copyWith(
                          fontSize: 16,
                          color: MyColor.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Login Form
                  ElegantCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
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
                          label: 'Password',
                          hintText: 'Enter your password',
                          controller: passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            }
                            if (value!.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              RtLScreenTransition(
                                screen: const ResetPasswordScreen(),
                              ).navigate(context);
                            },
                            child: Text(
                              'Forgot Password?',
                              style: outfitMedium.copyWith(
                                color: MyColor.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  GetBuilder<AuthController>(builder: (authController) {
                    return ModernButton(
                      text: 'Sign In',
                      isLoading: authController.isLoading,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        authController
                            .login(
                                emailController.text, passwordController.text)
                            .then((responseModel) {
                          if (responseModel.isSuccess) {
                            homeController.getUsers();
                            Navigator.of(context).pop();
                            FadeScreenTransition(
                              screen: const HomeScreen(),
                            ).navigate(context);
                          } else {
                            MySnakeBar.showSnakeBar(
                              'Sign In',
                              responseModel.message ?? '',
                            );
                          }
                        }).catchError((error) {
                          MySnakeBar.showSnakeBar(
                            'Sign In',
                            'Something went wrong!',
                          );
                          authController.updateError();
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Register Button
                  ModernButton(
                    text: 'Create Account',
                    isOutlined: true,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Get.to(() => const RegisterScreen());
                    },
                  ),

                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  GetBuilder<AuthController>(builder: (authController) {
                    return ModernButton(
                      text: 'Sign In with Google',
                      icon: Icons.account_circle_outlined,
                      isLoading: authController.isLoading,
                      isOutlined: true,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        authController.googleSignIn().then((responseModel) {
                          if (responseModel.isSuccess) {
                            homeController.getUsers();
                            Navigator.of(context).pop();
                            FadeScreenTransition(
                              screen: const HomeScreen(),
                            ).navigate(context);
                          } else if (responseModel.code == 409) {
                            // Account linking required
                            MySnakeBar.showSnakeBar(
                              'Google Sign In',
                              'An account with this email already exists. Please link your Google account in the registration screen.',
                            );
                          } else {
                            MySnakeBar.showSnakeBar(
                              'Google Sign In',
                              responseModel.message ?? '',
                            );
                          }
                        }).catchError((error) {
                          MySnakeBar.showSnakeBar(
                            'Google Sign In',
                            'Something went wrong!',
                          );
                          authController.updateError();
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
