import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signer/src/ui/screens/secretPhrase.dart';
import 'package:signer/src/ui/widgets/primaryButton.dart';

import '../theme/app_Text_Styles.dart';
import '../theme/colors.dart';

class MnemonicRecoveryScreen extends StatefulWidget {
  const MnemonicRecoveryScreen({super.key});

  @override
  State<MnemonicRecoveryScreen> createState() => _MnemonicRecoveryScreenState();
}

class _MnemonicRecoveryScreenState extends State<MnemonicRecoveryScreen> {
  final List<String> mnemonicWords = [
    'time',
    'test',
    'amazing',
    'block',
    'check',
    'again',
    'pet',
    'store',
    'crowd',
    'tree',
    'ball',
    'pen',
  ]; // First word pre-filled as 'time' like in screenshot
  int currentWordIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor.value,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('Mnemonic Recovery', style: AppTextStyles.heading2),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed:
                                  currentWordIndex > 0
                                      ? () {
                                        setState(() {
                                          currentWordIndex--;
                                        });
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBtnColor.value,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text('Previous', style: AppTextStyles.buttonText),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed:
                                  mnemonicWords[currentWordIndex].isNotEmpty
                                      ? () {
                                        if (currentWordIndex < 11) {
                                          setState(() {
                                            currentWordIndex++;
                                          });
                                        }
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor.value,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text('Next', style: AppTextStyles.buttonText),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Word ${currentWordIndex + 1} of 12:', style: AppTextStyles.body),
                  const SizedBox(height: 24),
                  IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      decoration: BoxDecoration(
                        color: inputFieldBackgroundColor.value,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: inputFieldBorderColor.value),
                      ),
                      child: Center(
                        child: Text(
                          mnemonicWords[currentWordIndex].isEmpty ? ' ' : mnemonicWords[currentWordIndex],
                          style: AppTextStyles.heading1.copyWith(
                            color: mnemonicWords[currentWordIndex].isEmpty ? hintTextColor.value : primaryTextColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(width: Get.width / 2, child: PrimaryButton(onTap: () {
              }, text: 'Start Recovery')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Exit', style: AppTextStyles.body.copyWith(color: errorColor.value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
