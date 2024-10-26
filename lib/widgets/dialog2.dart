import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';

class OkejekDialog2 extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final List<Widget> actions;

  const OkejekDialog2({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor = Colors.white,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              Text(
                message,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: OkejekTheme.primary_color,
            radius: 45,
            child: Icon(
              icon,
              color: iconColor,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}

void showOkejekDialog({
  required String title,
  required String message,
  required IconData icon,
  Color iconColor = Colors.white,
  List<Widget>? actions,
}) {
  Get.dialog(
    OkejekDialog2(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      actions: actions ?? [
        TextButton(
          child: Text('OK'),
          onPressed: () => Get.back(),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}