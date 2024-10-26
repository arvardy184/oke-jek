import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class ImprovedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enableContact;
  final bool isNumberField;
  final VoidCallback? onContactPressed;
  final String? Function(String?)? validator;

  ImprovedTextField({
    required this.label,
    required this.controller,
    this.enableContact = false,
    this.isNumberField = false,
    this.onContactPressed,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: OkejekTheme.primary_color,
            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 1),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return 'Field ini tidak boleh kosong';
              }
              return null;
            },
            style: TextStyle(
              color: Colors.black87,
              fontSize: SizeConfig.safeBlockHorizontal * 3.8,
            ),
            keyboardType: isNumberField ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumberField
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Masukkan $label",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4,
                vertical: SizeConfig.safeBlockVertical * 2,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: enableContact
                  ? IconButton(
                      icon: Icon(Icons.contact_phone, color: OkejekTheme.primary_color),
                      onPressed: onContactPressed,
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
      ],
    );
  }
}