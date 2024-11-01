import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okecourier/okecourier_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// class OkeCourierLocationSearch extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// ignore: must_be_immutable
class OkeCourierLocationSearch extends StatelessWidget {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PanelController pc;
  bool isOriginSection;

  OkeCourierLocationSearch({
    required this.formKey,
    required this.pc,
    required this.isOriginSection,
  });

  final OkeCourierController okeCourierController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: SizeConfig.safeBlockHorizontal * 30 / 3.6,
              width: SizeConfig.safeBlockHorizontal * 30 / 3.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOriginSection ? OkejekTheme.primary_color : OkejekTheme.primary_color,
              ),
              margin: EdgeInsets.only(
                right: SizeConfig.safeBlockHorizontal * 10 / 3.6,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: Colors.white,
              ),
            ),
            Flexible(
              child: TextFormField(
                validator: RequiredValidator(
                  errorText: 'Pencarian tidak boleh kosong',
                ),
                onFieldSubmitted: (value) {
                  validate(okeCourierController, value);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: OkejekTheme.primary_color,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Pilih Lokasi..',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.safeBlockHorizontal * 4,
                    vertical: SizeConfig.safeBlockVertical * 2,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: Get.height * 0.03,
        ),
        Material(
          child: InkWell(
            onTap: () {
              Get.back();
              isOriginSection
                  ? okeCourierController.isOriginPickingFromMap.value = true
                  : okeCourierController.isDestionationPickingFromMap.value = true;
              pc.close();
            },
            child: Container(
              height: Get.height * 0.05,
              width: Get.width,
              child: Row(
                children: [
                  Icon(
                    Icons.location_searching,
                  ),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                  ),
                  Text(
                    'Pilih lokasi dari map',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  validate(OkeCourierController controller, String value) {
    if (formKey.currentState!.validate()) {
      if (isOriginSection) {
        controller.searchOriginPlace.value = value;
        controller.isSubmitOrigin.value = true;
      } else {
        controller.searchDestinationPlace.value = value;
        controller.isSubmitDestination.value = true;
      }
      controller.getCoordinatesfromPlace(value);
    }
  }
}
