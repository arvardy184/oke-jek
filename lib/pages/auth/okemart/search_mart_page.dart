import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/pages/auth/okemart/detail_outlet_mart_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchFoodPage extends StatefulWidget {
  @override
  _SearchFoodPageState createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final OkeMartController okeFoodController = Get.put(OkeMartController());
  final TextEditingController searchController = TextEditingController();
Timer? _debounce;
 @override
  void initState() {
    super.initState();
    searchController.text = "";
    performSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

 void performSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (okeFoodController.isLoading.value) return;
      okeFoodController.resetPagination();
      okeFoodController.getMartVendor(searchController.text);
    });
 }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Toko',style: TextStyle(color: Colors.white),),
        backgroundColor: OkejekTheme.primary_color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
  controller: searchController,
  decoration: InputDecoration(
    hintText: 'Cari toko...',
    suffixIcon: IconButton(
      icon: Icon(Icons.search),
      onPressed: performSearch,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    filled: true,
    fillColor: Colors.grey[200],
  ),
  onChanged: (_) => performSearch(),
)
          ),
          Expanded(
            child: Obx(() {
              print("build list outlet page");
              print("${okeFoodController.foodVendors.length}");
              if (okeFoodController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (okeFoodController.foodVendors.isEmpty) {
                return Center(child: Text('Tidak ada hasil'));
              } else {
                return ListView.builder(
                  itemCount: okeFoodController.foodVendors.length,
                  itemBuilder: (context, index) {
                    FoodVendor vendor = okeFoodController.foodVendors[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => DetailOutletPage(
                                  foodVendor: vendor,
                                  type: vendor.type == 'mart' ? 100 : 3,
                                ));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: vendor.imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendor.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        vendor.categories.isNotEmpty ? vendor.categories.first.name!: 'Tidak ada kategori',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        vendor.address,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}