import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:okejek_flutter/controller/auth/okemart/okemart_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';
import 'package:okejek_flutter/pages/auth/okemart/detail_outlet_mart_page.dart';

class OkeMartListOutletPage extends StatefulWidget {
  @override
  State<OkeMartListOutletPage> createState() => _OkeMartListOutletPageState();
}

class _OkeMartListOutletPageState extends State<OkeMartListOutletPage> {
  final OkeMartController okeFoodController = Get.find();
  // final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    okeFoodController.resetPagination();
    okeFoodController.getMartVendor( _searchController.text);
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //     okeFoodController.getMartVendor( _searchController.text);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (okeFoodController.isLoading.value ) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            )
          );
        } else if(okeFoodController.foodVendors.isEmpty) {
          return Center(
            child: Text(
              'No data found',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.builder(
          // controller: ,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: okeFoodController.foodVendors.length + 1,
          itemBuilder: (context, index) {
            if (index < okeFoodController.foodVendors.length) {
              return _buildFoodVendorItem(okeFoodController.foodVendors[index]);
            } else {
              return okeFoodController.hasMore.value
                 
                  ? const SizedBox()
                  : const SizedBox();
            }
          },
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Cari toko..',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodVendorItem(FoodVendor foodVendor) {
    return InkWell(
      onTap: () => Get.to(() => DetailOutletPage(foodVendor: foodVendor, type: 100)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVendorImage(foodVendor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodVendor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodVendor.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildVendorInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorImage(FoodVendor foodVendor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // ignore: unnecessary_null_comparison
        child: foodVendor.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: foodVendor.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: OkejekTheme.primary_color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: OkejekTheme.primary_color, //700
              ),
              const SizedBox(width: 4),
              Text(
                '4.5',
                style: TextStyle(
                  color: OkejekTheme.primary_color , //700
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 4),
              Text(
                '0.8 km',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}