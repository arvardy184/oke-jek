import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_controller.dart';
import 'package:okejek_flutter/controller/auth/store/store_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/pages/auth/okefood/detail_outlet_page.dart';

/// Menampilkan beberapa rekomendasi outlet pada halaman utama food / mart
class RecomendationOutlet extends StatelessWidget {
  final OkeFoodController okeFoodController = Get.find();
  final StoreController storeController = Get.put(StoreController());
  final DateTime currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: okeFoodController.getFoodVendor(),
      builder: (context, snapshot) {
       if(snapshot.hasData) {
            List<FoodVendor> listFoodVendor = snapshot.data as List<FoodVendor>; 
            debugPrint("data recom, ${listFoodVendor} ");
           return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outlet',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Get.to(() => ListOutletPage());
                      // Get.to(() => ListOutletPage());
                      // TODO : list outlet
                    },
                    child: Text(
                      'Lihat lebih',
                      style: TextStyle(
                        color: OkejekTheme.primary_color,
                        fontSize: SizeConfig.safeBlockHorizontal * 2.8,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: Get.height * 0.3,
                width: Get.width,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: listFoodVendor.length,
                    itemBuilder: (context, index) {
                      FoodVendor foodVendor = listFoodVendor[index];
                      // TODO : image url vendor ERROR
                      foodVendor.imageUrl =
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/330px-Good_Food_Display_-_NCI_Visuals_Online.jpg';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(
                              () => DetailOutletPage(
                                foodVendor: foodVendor,
                                type: 3,
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, SizeConfig.safeBlockHorizontal * 3.5,
                                  SizeConfig.safeBlockHorizontal * 7, SizeConfig.safeBlockHorizontal * 3.5),
                              height: Get.height * 0.15,
                              width: Get.width * 0.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: OkejekTheme.bg_color,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(foodVendor.imageUrl),
                                  fit: BoxFit.cover,
                                  colorFilter: storeController.isStoreOpen(foodVendor)
                                      ? ColorFilter.mode(Colors.transparent, BlendMode.color)
                                      : ColorFilter.mode(Colors.grey, BlendMode.color),
                                  onError: (exception, stackTrace) => Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: Get.width * 0.5,
                              child: Text(
                                foodVendor.name,
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.black87,
                                      fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }else{
          debugPrint("data recom ${snapshot} ");
          return Container();
        }

        // else {   
        //   List<FoodVendor> listFoodVendor = snapshot.data as List<FoodVendor>; 
        //   debugPrint("data recom ${listFoodVendor} ");
        //   return Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             'Outlet',
        //             style: TextStyle(
        //               color: Colors.black87,
        //               fontWeight: FontWeight.bold,
        //               fontSize: SizeConfig.safeBlockHorizontal * 3.5,
        //             ),
        //           ),
        //           TextButton(
        //             onPressed: () {
        //               // Get.to(() => ListOutletPage());
        //               // Get.to(() => ListOutletPage());
        //               // TODO : list outlet
        //             },
        //             child: Text(
        //               'Lihat lebih',
        //               style: TextStyle(
        //                 color: OkejekTheme.primary_color,
        //                 fontSize: SizeConfig.safeBlockHorizontal * 2.8,
        //               ),
        //             ),
        //           )
        //         ],
        //       ),
        //       Container(
        //         height: Get.height * 0.3,
        //         width: Get.width,
        //         child: NotificationListener<OverscrollIndicatorNotification>(
        //           onNotification: (overscroll) {
        //             overscroll.disallowIndicator();
        //             return true;
        //           },
        //           child: ListView.builder(
        //             scrollDirection: Axis.horizontal,
        //             shrinkWrap: true,
        //             physics: ClampingScrollPhysics(),
        //             itemCount: listFoodVendor.length,
        //             itemBuilder: (context, index) {
        //               FoodVendor foodVendor = listFoodVendor[index];
        //               // TODO : image url vendor ERROR
        //               foodVendor.imageUrl =
        //                   'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/330px-Good_Food_Display_-_NCI_Visuals_Online.jpg';
        //               return Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   GestureDetector(
        //                     onTap: () => Get.to(
        //                       () => DetailOutletPage(
        //                         foodVendor: foodVendor,
        //                         type: 3,
        //                       ),
        //                     ),
        //                     child: Container(
        //                       margin: EdgeInsets.fromLTRB(0, SizeConfig.safeBlockHorizontal * 3.5,
        //                           SizeConfig.safeBlockHorizontal * 7, SizeConfig.safeBlockHorizontal * 3.5),
        //                       height: Get.height * 0.15,
        //                       width: Get.width * 0.5,
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.all(Radius.circular(20)),
        //                         color: OkejekTheme.bg_color,
        //                         image: DecorationImage(
        //                           image: CachedNetworkImageProvider(foodVendor.imageUrl),
        //                           fit: BoxFit.cover,
        //                           colorFilter: storeController.isStoreOpen(foodVendor)
        //                               ? ColorFilter.mode(Colors.transparent, BlendMode.color)
        //                               : ColorFilter.mode(Colors.grey, BlendMode.color),
        //                           onError: (exception, stackTrace) => Icon(Icons.broken_image_outlined),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                   Flexible(
        //                     child: Container(
        //                       width: Get.width * 0.5,
        //                       child: Text(
        //                         foodVendor.name,
        //                         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        //                               color: Colors.black87,
        //                               fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        //                               overflow: TextOverflow.ellipsis,
        //                             ),
        //                         maxLines: 2,
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               );
        //             },
        //           ),
        //         ),
        //       ),
        //     ],
        //   );
        // }
      },
    );
  }
}
