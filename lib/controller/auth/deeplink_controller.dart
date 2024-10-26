import 'package:get/get.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:uni_links/uni_links.dart';

class DeeplinkController extends GetxController {
  final LandingController landingController = Get.find<LandingController>();

  var deeplinkUrl = ''.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initUnitLinks();
  }

  // void initState() {
  //   super.onInit();
  // }

  // void delete() {
  //   super.onDelete();
  // }

  Future<void> initUnitLinks() async {
    try {
      final initialLink = await getInitialLink();

      if (initialLink != null) {
        deeplinkUrl.value = initialLink;
      }
    } catch (e) {
      print(e);
    }

    uriLinkStream.listen((Uri? link) {
      if (link != null) {
        handleDeepLink(link.toString());
      }
    }, onError: (err) {
      print("error in deep link stream $err");
    });
  }

  void handleDeepLink(String link) {
    deeplinkUrl.value = link;
    isProcessing.value = true;

    var uri = Uri.parse(link);
    List<String> path = uri.path.split('/');

    if (path.length > 2) {
      if (path[2] == 'outlets') {
        String id = path[3];
        landingController.deepLinkId.value = id;
        landingController.deepLinkType.value = 'outlets';
        Get.toNamed('/deeplink-page');
      } else if (path[2] == 'orders') {
        String id = uri.queryParameters['order']!;
        landingController.deepLinkId.value = id;
        landingController.deepLinkType.value = 'order';
        Get.toNamed('/deeplink-page');
      } else if (path[2] == 'payments_callback') {
        handlePaymentCallback(uri);
      }
    }
    isProcessing.value = false;
  }

  void handlePaymentCallback(Uri uri) {
    String status = uri.queryParameters['status'] ?? '';
    String orderId = uri.queryParameters['order_id'] ?? '';

    switch (status) {
      case 'success':
        Get.toNamed('payment-success', arguments: orderId);
        break;
      case 'failed':
        Get.toNamed('payment-failed', arguments: orderId);
        break;
      case 'pending':
        Get.toNamed('payment-pending', arguments: orderId);
        break;
      case 'canceled':
        Get.toNamed('payment-canceled', arguments: orderId);
        break;
      default:
        Get.toNamed('payment-unknown', arguments: orderId);
        break;
    }
  }
}
