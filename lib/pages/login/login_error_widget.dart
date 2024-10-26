import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/login/login_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class LoginErrorWidget extends StatelessWidget {
  final LoginController loginController;

  LoginErrorWidget({required this.loginController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loginController.isLoginFailure.value) {
        return _buildErrorMessage(context);
      }
      return SizedBox.shrink();
    });
  }

  Widget _buildErrorMessage(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Login Gagal',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Email atau password yang Anda masukkan salah. Silakan periksa kembali dan coba lagi.',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            ),
          ),
          // SizedBox(height: 8),
          // Text(
          //   'Saran:',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     color: Colors.red.shade700,
          //     fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          //   ),
          // ),
          // Text(
          //   '• Pastikan ejaan email Anda benar\n• Periksa apakah Caps Lock aktif\n• Klik lupa password jika Anda lupa',
          //   style: TextStyle(
          //     color: Colors.red.shade700,
          //     fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          //   ),
          // ),
          // SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => loginController.isLoginFailure.value = false,
              child: Text(
                'Tutup',
                style: TextStyle(color: OkejekTheme.primary_color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}