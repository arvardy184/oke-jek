import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:okejek_flutter/controller/auth/profile/profile_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class EditProfilePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final UserController userController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  initialValue: userController.name.value,
                  onSaved: (value) => profileController.name.value = value ?? userController.name.value,
                  validator: RequiredValidator(errorText: 'Nama tidak boleh kosong'),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 3),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  initialValue: userController.email.value,
                  onSaved: (value) => profileController.email.value = value ?? userController.email.value,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Email tidak boleh kosong'),
                    EmailValidator(errorText: 'Format email salah')
                  ]),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 3),
                _buildPasswordField(),
                SizedBox(height: SizeConfig.safeBlockVertical * 3),
                _buildTextField(
                  label: 'Nomor Telepon',
                  icon: Icons.phone_outlined,
                  initialValue: userController.contactMobile.value,
                  onSaved: (value) => profileController.contactPhone.value = value ?? userController.contactMobile.value,
                  validator: RequiredValidator(errorText: 'Nomor telepon tidak boleh kosong'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 5),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: OkejekTheme.primary_color),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Edit Profil',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.safeBlockHorizontal * 4,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Colors.black87, fontSize: SizeConfig.safeBlockHorizontal * 3.5),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: OkejekTheme.primary_color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: OkejekTheme.primary_color),
          borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: true,
          onSaved: (value) => profileController.password.value = value ?? '',
          style: TextStyle(color: Colors.black87, fontSize: SizeConfig.safeBlockHorizontal * 3.5),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.vpn_key_outlined, color: OkejekTheme.primary_color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: OkejekTheme.primary_color),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 4, top: 8),
          child: Text(
            '* Biarkan kosong untuk mempertahankan password lama',
            style: TextStyle(color: Colors.grey, fontSize: SizeConfig.safeBlockHorizontal * 3),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => ElevatedButton(
      onPressed: profileController.isLoading.value ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: OkejekTheme.primary_color,
        padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
      ),
      child: profileController.isLoading.value
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                fontWeight: FontWeight.bold,
              ),
            ),
    ));
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      profileController.editProfil();
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: OkejekTheme.primary_color,
        colorText: Colors.white,
      );
    }
  }
}