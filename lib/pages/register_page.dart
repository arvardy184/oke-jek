import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/register/register_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/pages/login/login_page.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: OkejekTheme.primary_color,
        elevation: 0.0,
        title: Text('Daftar akun baru', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5.6),
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: Get.height * 0.05),
                  _buildTextField('Nama Pengguna', Icons.person_outline, registerController.namaController, _validateName),
                  _buildTextField('Alamat Email', Icons.email_outlined, registerController.emailController, _validateEmail),
                  _buildPasswordField('Password', registerController.passwordController),
                  _buildPasswordField('Konfirmasi Password', registerController.confirmPasswordController, isConfirmPassword: true),
                  _buildTextField('No. HP', Icons.phone_outlined, registerController.telphoneController, _validatePhone, isPhone: true),
                  SizedBox(height: Get.height * 0.03),
                  _buildRegisterButton(context),
                  SizedBox(height: Get.height * 0.05),
                  _buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, String? Function(String?) validator, {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: TextStyle(color: Colors.black54, fontSize: SizeConfig.safeBlockHorizontal * 3.3),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54, fontSize: SizeConfig.safeBlockHorizontal * 3),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {bool isConfirmPassword = false}) {
    return Obx(() => Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: registerController.isPasswordHidden.value,
        validator: (value) => isConfirmPassword ? _validateConfirmPassword(value) : _validatePassword(value),
        style: TextStyle(color: Colors.black54, fontSize: SizeConfig.safeBlockHorizontal * 3.3),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54, fontSize: SizeConfig.safeBlockHorizontal * 3),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
          suffixIcon: IconButton(
            icon: Icon(
              registerController.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: () => registerController.togglePasswordVisibility(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ));
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Obx(() => ElevatedButton(
      onPressed: registerController.isLoading.value ? null : () => _validateAndSubmit(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: OkejekTheme.primary_color,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OkejekTheme.button_rounded_corner)),
      ),
      child: registerController.isLoading.value
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Daftar Sekarang', style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.5,color: Colors.white)),
    ));
  }

  Widget _buildLoginLink(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.5, color: OkejekTheme.primary_color),
        children: [
          TextSpan(text: 'Sudah punya akun? '),
          TextSpan(
            text: 'Silakan login',
            style: TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () => Get.off(() => LoginPage()),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama Pengguna tidak boleh kosong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email salah';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password harus minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != registerController.passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'No. HP tidak boleh kosong';
    }
    if (!value.startsWith('0')) {
      return 'No. HP harus dimulai dengan 0';
    }
    if (value.length < 9 || value.length > 12) {
      return 'No. HP harus 9-12 digit';
    }
    return null;
  }

  void _validateAndSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      registerController.register(failureSnackbar);
    }
  }

  void failureSnackbar(String message) {
    Get.snackbar(
      'Kesalahan',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.all(8),
    );
  }
}