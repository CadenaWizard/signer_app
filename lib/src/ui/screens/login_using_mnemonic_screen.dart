import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/appController.dart';
import '../theme/colors.dart';
import '../widgets/appTextField.dart';
import '../widgets/primaryButton.dart';
import 'mnemonic_screen.dart';

class LoginUsingMnemonicScreen extends StatefulWidget {
  const LoginUsingMnemonicScreen({super.key});

  @override
  State<LoginUsingMnemonicScreen> createState() =>
      _LoginUsingMnemonicScreenState();
}

class _LoginUsingMnemonicScreenState extends State<LoginUsingMnemonicScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mnemonicController = TextEditingController();

  AppController appController = Get.find<AppController>();

  String? emailError;
  String? passwordError;

  bool _isVerifying = false;

  bool validateEmail(String email) {
    return GetUtils.isEmail(email);
  }

  Future<void> _verify() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    setState(() {
      emailError = validateEmail(email) ? null : "Enter a valid email address";


      if (password.isEmpty) {
        passwordError = "Please Enter Password";
      } else {
        passwordError = null;
      }

    });

    if (emailError != null ||
        passwordError != null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MnemonicScreen(
          email: email,
          password: password,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      if (emailError != null && validateEmail(emailController.text.trim())) {
        setState(() => emailError = null);
      }
    });
    // Listener for password field to clear error when user types
    passwordController.addListener(() {
      if (passwordError != null && passwordController.text.isNotEmpty) {
        setState(() => passwordError = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: primaryBackgroundColor.value,
        appBar: AppBar(
          backgroundColor: surfaceColor.value,
          foregroundColor: primaryTextColor.value,
          elevation: 0,
          title: const Text('Login'),
          centerTitle: true,
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  const SizedBox(height: 64),
                  Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor.value,
                    ),
                  ),
                  Text(
                    "Login using your recovery phrase",
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryTextColor.value.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "Enter your details below to continue:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor.value.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                      hintText: "Email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress),
                  if (emailError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(emailError!,
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),


                  AppTextField(
                      hintText: "Password",
                      controller: passwordController,
                      isPassword: true,
                      obscureText: true),
                  if (passwordError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(passwordError!,
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    // text: "Login",
                    text: "Proceed",
                    onTap: _verify,
                  ),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
