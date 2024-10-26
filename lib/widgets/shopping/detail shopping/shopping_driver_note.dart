import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okeshop/detail_order_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class ShoppingDriverNote extends StatelessWidget {
  final TextEditingController driverNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DetailOrderShopController detailShopController = Get.find();
    return Obx(
      () => ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        reverse: true,
        children: [
          detailShopController.driverNote.value.isEmpty
              ? TextButton(
                  onPressed: () {
                    driverNoteDialog(detailShopController, context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: OkejekTheme.primary_color,
                        size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                      ),
                      SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                      ),
                      Text(
                        'Pesan untuk driver',
                        style: TextStyle(
                          color: OkejekTheme.primary_color,
                          fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                        ),
                      )
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    driverNoteDialog(detailShopController, context);
                  },
                  child: Container(
                    height: Get.height * 0.07,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal * 10 / 3.6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 20 / 3.6),
                            child: Obx(
                              () => Text(
                                detailShopController.driverNote.value,
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                  color: Colors.black54,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            driverNoteController.clear();
                            detailShopController.setDriverNote('');
                          },
                          icon: Icon(
                            Icons.close_outlined,
                            size: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
        ].reversed.toList(),
      ),
    );
  }


// StylishDialogs.showAddNoteDialog(context, onSave)
  Future<dynamic> driverNoteDialog(DetailOrderShopController detailShopController, BuildContext context) {
 return  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        content: Container(
          width: SizeConfig.screenWidth * 0.8,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Catatan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OkejekTheme.primary_color,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: driverNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan catatan di sini...',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: OkejekTheme.primary_color, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Batal'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87, backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // onSave(noteController.text);
                   
                    if (driverNoteController.text.isBlank!) {
                      Get.back();
                    } else {
                      detailShopController.setDriverNote(driverNoteController.text);
                      Get.back();
                    }
                    },
                    child: Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: OkejekTheme.primary_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
    );
  }
}
