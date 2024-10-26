import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/pages/auth/okerental/listrental_page.dart';

class OkeRentalPage extends StatelessWidget {
  const OkeRentalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: OkejekTheme.primary_color,
        backgroundColor: OkejekTheme.bg_color,
        elevation: 0,
        title: Text('Oke Rent', style: TextStyle(color: OkejekTheme.primary_color)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(height: 40),
                      _buildLogo(),
                      SizedBox(height: 40),
                      _buildTitle(),
                      SizedBox(height: 20),
                      _buildDescription(),
                    ],
                  ),
                ),
              ),
            ),
            _buildRentalButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Hero(
        tag: 'logoHero',
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [OkejekTheme.primary_color.withOpacity(0.8), OkejekTheme.primary_color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/logo_rent.jpg'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Siap mengantar anda kemana saja",
      textAlign: TextAlign.center,
      style: TextStyle(
        
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: OkejekTheme.primary_color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      "Nikmati pengalaman perjalanan yang nyaman dan aman bersama OkeRental. "
      "Kami menyediakan kendaraan terbaik untuk kebutuhan Anda. Pesan sekarang dan perjalanan anda menjadi lebih mudah!",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: OkejekTheme.primary_color.withOpacity(0.8),
        height: 1.6,
      ),
    );
  }

  Widget _buildRentalButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Get.to(() => ListRentalCarPage());
        },
        child: Text(
          "Sewa Oke Car",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: OkejekTheme.primary_color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: OkejekTheme.primary_color.withOpacity(0.4),
          elevation: 8, // Button color when pressed
        ),
      ),
    );
  }
}
