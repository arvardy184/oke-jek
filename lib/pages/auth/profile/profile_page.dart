import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okejek_flutter/controller/api/user_controller.dart';
import 'package:okejek_flutter/controller/auth/profile/profile_controller.dart';
import 'package:okejek_flutter/controller/logout/logout_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/defaults/url.dart';
import 'package:okejek_flutter/pages/auth/profile/edit_profile_page.dart';
import 'package:okejek_flutter/pages/auth/profile/help_and_support_page.dart';
import 'package:okejek_flutter/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfilePage extends StatelessWidget {
  final LogoutController logoutController = Get.find();
  final UserController userController = Get.find();
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildMenuSections(context),
                const SizedBox(height: 24),
              
                _buildAppVersion(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      // expandedHeight: ,
      floating: false,
      pinned: false,
      backgroundColor: OkejekTheme.primary_color,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                OkejekTheme.primary_color,
                OkejekTheme.primary_color.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          _buildProfileInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Obx(() => Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: OkejekTheme.primary_color,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: userController.imageUrl.value.isEmpty
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: OkejekTheme.primary_color,
                  )
                : CachedNetworkImage(
                    imageUrl: userController.imageUrl.value,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 50,
                      color: OkejekTheme.primary_color,
                    ),
                  ),
          ),
        )),
        // Positioned(
        //   bottom: 0,
        //   right: 0,
        //   child: Container(
        //     padding: const EdgeInsets.all(4),
        //     decoration: BoxDecoration(
        //       color: OkejekTheme.primary_color,
        //       shape: BoxShape.circle,
        //     ),
        //     child: Icon(
        //       Icons.edit,
        //       size: 20,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Obx(() => Text(
          userController.name.value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )),
        const SizedBox(height: 8),
        _buildInfoItem(
          icon: Icons.email_outlined,
          text: userController.email.value,
        ),
        const SizedBox(height: 4),
        _buildInfoItem(
          icon: Icons.phone_outlined,
          text: userController.contactMobile.value,
        ),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSections(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuGroup(
            title: 'Account Settings',
            items: [
              MenuItemData(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => _navigateToEditProfile(context),
              ),
              MenuItemData(
                icon: Icons.support_agent,
                title: 'Help & Support',
                onTap: () => _navigateToHelpSupport(context),
              ),
            ],
          ),
          Divider(height: 1),
          _buildMenuGroup(
            title: 'Business',
            items: [
              MenuItemData(
                icon: Icons.store,
                title: 'Become a Merchant',
                onTap: () => showMerchantDialog(context),
                isSpecial: true,
              ),
            ],
          ),
          Divider(height: 1),
          _buildMenuGroup(
            title: 'Legal',
            items: [
              MenuItemData(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => profileController.openBrowserPrivacy(),
              ),
              MenuItemData(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => profileController.openBrowserTermsAndCondition(),
              ),
            ],
          ),
          Divider(height: 1),
          _buildMenuItem(
            MenuItemData(
              icon: Icons.exit_to_app,
              title: 'Sign Out',
              onTap: () => showLogoutDialog(),
              isDestructive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)).toList(),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.isSpecial
                    ? OkejekTheme.primary_color.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: item.isDestructive
                    ? Colors.red
                    : item.isSpecial
                        ? OkejekTheme.primary_color
                        : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  color: item.isDestructive
                      ? Colors.red
                      : item.isSpecial
                          ? OkejekTheme.primary_color
                          : Colors.grey[800],
                  fontWeight: item.isSpecial ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget logout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.exit_to_app_outlined,
                color: OkejekTheme.primary_color,
                size: SizeConfig.safeBlockHorizontal * 30 / 3.6,
              ),
            ],
          ),
          title: Text(
            'Keluar',
            style: TextStyle(
              color: OkejekTheme.primary_color,
              fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
            ),
          ),
          onTap: () {
            showLogoutDialog();
          },
        ),
      ],
    );
    


  }


  showLogoutDialog() {
    showOkejekDialog(
      title: "Keluar",
      message: "Apakah Anda yakin ingin keluar dari akun ini?",
      cancelText: "Batal",
      confirmText: "Keluar",
      onConfirm: () {
        logoutController.logout();
      },
      confirmColor: OkejekTheme.primary_color,
      icon: Icons.exit_to_app,
    );
  }Widget _buildAppVersion()  {
    
    return Text(
      'Version ${userController.versionApp.value}',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EditProfilePage(),
      withNavBar: false,
    );
    profileController.resetController();
  }

  void _navigateToHelpSupport(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: HelpSupportPage(),
      withNavBar: false,
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isSpecial;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isSpecial = false,
  });
}

 void showMerchantDialog(BuildContext context) {
    showOkejekDialog(
      title: "OkeMerchant",
      message: "Silahkan download aplikasi OkeMerchant dari Playstore / Appstore",
      cancelText: "Batal",
      confirmText: "Lanjutkan",
      onConfirm: () {
        gotoMerchantWeb();
        Get.back();
      },
      icon: Icons.store,
    );
  }

 

  void gotoMerchantWeb() async {
    String url = OkejekBaseURL.registerMerchant;

    await canLaunchUrlString(url) ? await launchUrlString(url) : throw 'Could not launch $url';
  }

  void showOkejekDialog({
    required String title,
    required String message,
    String? cancelText,
    required String confirmText,
    VoidCallback? onCancel,
    required VoidCallback onConfirm,
    Color? confirmColor,
    required IconData icon,
  }) {
    Get.dialog(
      OkejekDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: onCancel,
        onConfirm: onConfirm,
        confirmColor: confirmColor,
        icon: icon,
      ),
      barrierDismissible: false,
    );
  }
