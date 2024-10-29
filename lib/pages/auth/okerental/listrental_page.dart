import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/okerental/okerental_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/rental_model.dart';
import 'package:okejek_flutter/pages/auth/okerental/detail_order_rental_page.dart';
import 'package:shimmer/shimmer.dart'; // For number formatting

class ListRentalCarPage extends StatelessWidget {
  final OkeRentController controller = Get.put(OkeRentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Paket', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                      child: Container(
                        // padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 100,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!);
                },
                itemCount: 5),
          );
        } else if (controller.packages.isEmpty) {
          return Center(child: Text('Tidak ada paket tersedia'));
        } else {
          return ListView.builder(
            itemCount: controller.packages.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final package = controller.packages[index];
              print("melihat info ${package.pricings}");

              return PackageCard(
                package: package,
              );
            },
          );
        }
      }),
    );
  }
}

class PackageCard extends StatelessWidget {
  final RentalPackage package;

  PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final okeRentalController = Get.find<OkeRentController>();
    return GestureDetector(
      onTap: () {
        okeRentalController.setSelectedPackage(package);

        final pricing = package.pricings?[0];
        print("object : ${pricing!.id}");
        okeRentalController.setPricingId(pricing.id!);

        // print("melihat info2 ${pricing}");

        // okeRentalController.setPricingId(pricing.id!);
        Get.to(() => DetailOrderRentalPage(), transition: Transition.rightToLeft);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple[100],
                child: Stack(
                  children: [
                    Icon(Icons.directions_car, size: 30, color:OkejekTheme  .primary_color),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(Icons.access_time, size: 15, color: OkejekTheme.primary_color),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${package.description} menit',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(package.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: OkejekTheme.primary_color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
