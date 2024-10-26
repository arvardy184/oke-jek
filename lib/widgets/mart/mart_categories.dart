import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_categories_model.dart';
import 'package:okejek_flutter/pages/auth/okemart/list_mart_page.dart';

class MartCategories extends StatelessWidget {
  final OkeMartController controller = Get.find();

  // Map untuk menghubungkan kategori ID dengan asset image path
   final Map<int, String> categoryAssets = {
    24: 'assets/images/icon_mart/atk.png',
    25: 'assets/images/icon_mart/otomotif.png',
    26: 'assets/images/icon_mart/bmp.png',
    27: 'assets/images/icon_mart/bakery.png',
    28: 'assets/images/icon_mart/daging.png',
    29: 'assets/images/icon_mart/elektronik.png',
    30: 'assets/images/icon_mart/garden.png',
    31: 'assets/images/icon_mart/phone.png',
    32: 'assets/images/icon_mart/kesehatan.png',
    33: 'assets/images/icon_mart/snack.png',
    34: 'assets/images/icon_mart/drink.png',
    35: 'assets/images/icon_mart/prt.png',
    36: 'assets/images/icon_mart/beauty.png',
    37: 'assets/images/icon_mart/hewan.png',
    38: 'assets/images/icon_mart/frozen.png',
    39: 'assets/images/icon_mart/fresh.png',
    40: 'assets/images/icon_mart/eggmilk.png',
    41: 'assets/images/icon_mart/toys.png',
  };

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: FutureBuilder<List<FoodVendorCategories>>(
        future: controller.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } 
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container();
          }

          List<FoodVendorCategories> categories = snapshot.data!;
          
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     // Handle view all categories
                    //   },
                    //   child: Text(
                    //     'Lihat Semua',
                    //     style: TextStyle(
                    //       color: Theme.of(context).primaryColor,
                    //       fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: Get.height * 0.35,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) => 
                      categoryItem(categories[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget categoryItem(FoodVendorCategories category) {
    return GestureDetector(
      onTap: () {
        controller.setSelectedCategoryId(category.id);
        Get.to(() => OkeMartListOutletPage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 8,
              width: SizeConfig.blockSizeVertical * 8,
              // padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                categoryAssets[category.id] ?? 'assets/images/icon_mart/atk.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.category_outlined,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}