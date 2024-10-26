import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okefood/okefood_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_categories_model.dart';
import 'package:okejek_flutter/pages/auth/okefood/list_outlet_page.dart';

class CategoriesMenu extends StatelessWidget {
  final OkeFoodController controller = Get.find();

  // Map kategori makanan dengan icon yang spesifik
  final Map<int, IconData> foodIcons = {
    6: Icons.dinner_dining, // Aneka Lalapan
    2: Icons.rice_bowl, // Aneka Nasi
    23: Icons.lunch_dining, // Ayam Geprek
    1: Icons.ramen_dining, // Bakmie
    5: Icons.soup_kitchen, // Bakso
    20: Icons.access_time_filled, // Buka 24 Jam
    19: Icons.restaurant_menu, // Chinese Food
    16: Icons.coffee, // Coffee
    14: Icons.donut_large, // Donuts
    9: Icons.fastfood, // Fast Food
    21: Icons.eco, // Fresh Food
    11: Icons.food_bank, // Indian and Middle Eastern
    15: Icons.cake, // Jajanan dan Oleh-oleh
    12: Icons.set_meal, // Japanese Food
    13: Icons.restaurant, // Korean Food
    3: Icons.bakery_dining, // Martabak Manis
    4: Icons.egg_alt, // Martabak Telur
    17: Icons.local_drink, // Minuman Segar
    8: Icons.local_pizza, // Pizza
    7: Icons.kebab_dining, // Sate
    22: Icons.waves, // Seafood
    18: Icons.icecream, // Sweet & Dessert
    10: Icons.home_filled, // Traditional food
  };

  // Map warna untuk kategori yang lebih relevan dengan makanan
  final Map<int, Color> categoryColors = {
    6: const Color(0xFFE8F5E9), // Lalapan - Green light
    2: const Color(0xFFFFF3E0), // Nasi - Orange light
    23: const Color(0xFFFFEBEE), // Ayam Geprek - Red light
    1: const Color(0xFFFFF8E1), // Bakmie - Amber light
    5: const Color(0xFFE3F2FD), // Bakso - Blue light
    20: const Color(0xFFEDE7F6), // 24 Jam - Deep Purple light
    19: const Color(0xFFFCE4EC), // Chinese - Pink light
    16: const Color(0xFFEFEBE9), // Coffee - Brown light
    14: const Color(0xFFF3E5F5), // Donuts - Purple light
    9: const Color(0xFFFFEBEE), // Fast Food - Red light
    21: const Color(0xFFE8F5E9), // Fresh Food - Green light
    11: const Color(0xFFFFF3E0), // Indian - Orange light
    15: const Color(0xFFFCE4EC), // Jajanan - Pink light
    12: const Color(0xFFE3F2FD), // Japanese - Blue light
    13: const Color(0xFFFFEBEE), // Korean - Red light
    3: const Color(0xFFFFF8E1), // Martabak Manis - Amber light
    4: const Color(0xFFFFF3E0), // Martabak Telur - Orange light
    17: const Color(0xFFE3F2FD), // Minuman - Blue light
    8: const Color(0xFFFFEBEE), // Pizza - Red light
    7: const Color(0xFFFFF3E0), // Sate - Orange light
    22: const Color(0xFFE3F2FD), // Seafood - Blue light
    18: const Color(0xFFF3E5F5), // Dessert - Purple light
    10: const Color(0xFFE8F5E9), // Traditional - Green light
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
            return SizedBox(
              height: Get.height * 0.3,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container();
          }

          List<FoodVendorCategories> categories = snapshot.data!;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.safeBlockHorizontal * 4.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle view all categories
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: Get.height * 0.32,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) => categoryItem(categories[index], context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget categoryItem(FoodVendorCategories category, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.setSelectedCategoryId(category.id);
        Get.to(() => OkeFoodListOutletPage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
              decoration: BoxDecoration(
                color: categoryColors[category.id] ?? const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                foodIcons[category.id] ?? Icons.restaurant_menu,
                color: Theme.of(context).primaryColor,
                size: SizeConfig.blockSizeVertical * 4,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
