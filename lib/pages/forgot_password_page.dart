import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lupa Password'),
        backgroundColor: OkejekTheme.primary_color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.05),
                Text(
                  'Lupa Password?',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Text(
                  'Masukkan alamat email Anda untuk menerima instruksi reset password.',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement password reset logic
                      _showResetPasswordDialog(context);
                    }
                  },
                  child: Text('Kirim ', style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.5,color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OkejekTheme.primary_color,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Kembali ke Halaman Login',
                      style: TextStyle(color: OkejekTheme.primary_color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Text('Instruksi reset password telah dikirim ke ${emailController.text}. Silakan periksa email Anda.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Get.back(); // Kembali ke halaman login
              },
            ),
          ],
        );
      },
    );
  }
}