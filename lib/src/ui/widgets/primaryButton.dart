import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_Text_Styles.dart';
import '../theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isOutlined;
  final bool isLoading;
  final String loadingText;

  const PrimaryButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.isOutlined = false,
      this.isLoading = false,
      this.loadingText = ''});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : primaryColor.value,
            borderRadius: BorderRadius.circular(10),
            border: isOutlined ? Border.all(color: primaryColor.value) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                    height: 28.0,
                    width: 28.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: Colors.white,
                        backgroundColor: Colors.transparent)),
              if (isLoading) const SizedBox(width: 14),
              Text(isLoading ? loadingText : text,
                  style: AppTextStyles.buttonText.copyWith(
                      color: isOutlined
                          ? primaryColor.value
                          : primaryTextColor.value),textAlign: TextAlign.center,),
            ],
          ),
        ),
      );
    });
  }
}
