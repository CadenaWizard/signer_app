import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signer/src/ui/screens/createWallet/seed_phrase.dart';
import 'package:signer/src/ui/theme/app_Text_Styles.dart';
import 'package:signer/src/ui/theme/colors.dart';
import 'package:signer/src/ui/widgets/appTextField.dart';
import 'package:signer/src/ui/widgets/primaryButton.dart';
import 'package:signer/src/ui/screens/signupScreen.dart';

class ImportWalletScreen extends StatefulWidget {
  final String email;
  final String password;
  const ImportWalletScreen({super.key, required this.email, required this.password});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final TextEditingController mnemonicController = TextEditingController();

  String? mnemonicError;

  bool isValidMnemonic(String phrase) {
    final words = phrase.trim().split(RegExp(r'\s+'));
    return words.length == 12 || words.length == 24;
  }

  void handleImport() {
    final phrase = mnemonicController.text.trim();

    setState(() {
      mnemonicError = isValidMnemonic(phrase) ? null : 'Enter a valid 12 or 24-word phrase';
    });

    if (mnemonicError != null) return;

    // Navigate to SeedPhraseScreen
    Get.to(() => SeedPhraseScreen(mnemonic: phrase, email: widget.email, password: widget.password, fromPage: "import_wallet"));
  }

  @override
  void initState() {
    super.initState();

    mnemonicController.addListener(() {
      if (mnemonicError != null && isValidMnemonic(mnemonicController.text.trim())) {
        setState(() => mnemonicError = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: primaryBackgroundColor.value,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text("Import Wallet", style: AppTextStyles.heading2.copyWith(color: primaryTextColor.value)),
                      const SizedBox(height: 32),

                      /// Mnemonic Field
                      AppTextField(hintText: "Enter your secret recovery phrase", controller: mnemonicController, keyboardType: TextInputType.multiline),
                      if (mnemonicError != null) Align(alignment: Alignment.centerLeft, child: Text(mnemonicError!, style: const TextStyle(color: Colors.red, fontSize: 12))),

                      const SizedBox(height: 32),

                      /// Import Wallet Button
                      const SizedBox(height: 16),

                      /// Optional Create New Wallet
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                PrimaryButton(text: "Import Wallet", onTap: handleImport),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
