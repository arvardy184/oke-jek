import 'package:cached_network_image/cached_network_image.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okemart/detail_outlet_controller.dart';
import 'package:okejek_flutter/controller/auth/store/store_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/auth/food/food_vendor_model.dart';

class OutletMenuList extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  final DetailOutletController controller = Get.put(DetailOutletController());
  final FoodVendor foodVendor;
  final int index;
  final StoreController storeController = Get.find();

  OutletMenuList({
    required this.foodVendor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final menu = foodVendor.menus[index];
    final isStoreOpen = storeController.isStoreOpen(foodVendor);
    
    return Entry.opacity(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: isStoreOpen ? () => _showMenuDetail(context, menu) : null,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: isStoreOpen ? 1 : 0.5,
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuImage(menu),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMenuInfo(menu),
                          const SizedBox(height: 8),
                          _buildPriceAndAction(menu, isStoreOpen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuImage(dynamic menu) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: menu.imageUrl != null && menu.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: menu.imageUrl,
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
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 32,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildMenuInfo(dynamic menu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          menu.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (menu.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            menu.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPriceAndAction(dynamic menu, bool isStoreOpen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currencyFormatter.format(menu.price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (!isStoreOpen)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Toko Tutup',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        if (isStoreOpen)
          Obx(() {
            return controller.cartQtyMap.containsKey(menu.id)
                ? _buildQuantityControl(menu)
                : _buildAddButton(menu);
          }),
      ],
    );
  }

  Widget _buildAddButton(dynamic menu) {
    return ElevatedButton(
      onPressed: () => controller.addToCart(menu.id, menu.price, menu),
      style: ElevatedButton.styleFrom(
        backgroundColor: OkejekTheme.primary_color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 20),
          SizedBox(width: 4),
          Text('Tambah'),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(dynamic menu) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: OkejekTheme.primary_color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.remove,
            onPressed: () {
              if (controller.cartQtyMap[menu.id] == 1) {
                controller.removeFromCart(menu.id, menu.price, menu);
              } else {
                controller.subsQtyItem(menu.id, menu.price);
              }
            },
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            child: Text(
              controller.cartQtyMap[menu.id].toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildControlButton(
            icon: Icons.add,
            onPressed: () => controller.addQtyItem(menu.id, menu.price),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showMenuDetail(BuildContext context, dynamic menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuImage(menu),
            const SizedBox(height: 16),
            _buildMenuInfo(menu),
            const SizedBox(height: 16),
            _buildPriceAndAction(menu, true),
          ],
        ),
      ),
    );
  }
}