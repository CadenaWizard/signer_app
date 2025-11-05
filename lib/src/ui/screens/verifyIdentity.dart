import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signer/services/storage_service.dart';
import 'package:signer/src/ui/screens/secretPhrase.dart';
import 'package:signer/src/ui/widgets/appTextField.dart';

import '../theme/app_Text_Styles.dart';
import '../theme/colors.dart';
import '../widgets/primaryButton.dart';

class VerifyIdentity extends StatefulWidget {
  const VerifyIdentity({super.key});

  @override
  State<VerifyIdentity> createState() => _VerifyIdentityState();
}

class _VerifyIdentityState extends State<VerifyIdentity> {
  final TextEditingController w1Controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController w2Controller = TextEditingController();

  String? error;
  int wordIndex1 = 0;
  int wordIndex2 = 0;

  @override
  void initState() {
    super.initState();
    generateRandomIndices();
  }

  void generateRandomIndices() {
    final random = Random();
    List<int> indices = List.generate(12, (i) => i)..shuffle(random);
    setState(() {
      wordIndex1 = indices[0];
      wordIndex2 = indices[1];
    });
  }

  void verifyIdentity() async {
    // final word1 = w1Controller.text.trim().toLowerCase();
    // final word2 = w2Controller.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    final loggedInEmail = await StorageService.getLoggedInEmail();
    final user = await StorageService.getUserByEmail(loggedInEmail ?? '');

    if (user == null) {
      setState(() => error = 'User not found');
      return;
    }

    if (user['password'] != password) {
      setState(() => error = 'Incorrect password');
      return;
    }

    setState(() => error = null);
    passwordController.clear();
    final mnemonicWords = (user['mnemonic'] ?? '').split(' ');

    // if (mnemonicWords.length < 12 ||
    //     word1 != mnemonicWords[wordIndex1] ||
    //     word2 != mnemonicWords[wordIndex2]) {
    //   setState(() => error = 'Incorrect mnemonic words');
    //   return;
    // }
    //
    // setState(() => error = null);
    //
    // w1Controller.clear();
    // w2Controller.clear();
    Get.to(() => SecretPhraseScreen(mnemonicPhrase: mnemonicWords));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: primaryBackgroundColor.value,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Verify your Identity",
                    style: AppTextStyles.heading2
                        .copyWith(color: primaryTextColor.value)),
                // Text(
                //     'Enter your password and the following words from your secret recovery phrase',
                //     style: AppTextStyles.body,
                //     textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text(
                  'Enter your password',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: AppTextStyles.body
                            .copyWith(color: hintTextColor.value))),
                SizedBox(height: 8),
                AppTextField(
                    hintText: "Password",
                    isPassword: true,
                    controller: passwordController,
                    obscureText: true),
                /* Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Word ${wordIndex1 + 1}',
                        style: AppTextStyles.body
                            .copyWith(color: hintTextColor.value))),
                AppTextField(
                    hintText: "Word ${wordIndex1 + 1}",
                    controller: w1Controller),
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Word ${wordIndex2 + 1}',
                        style: AppTextStyles.body
                            .copyWith(color: hintTextColor.value))),
                AppTextField(
                    hintText: "Word ${wordIndex2 + 1}",
                    controller: w2Controller),*/
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                SizedBox(height: 60),

                PrimaryButton(text: "Verify", onTap: verifyIdentity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
