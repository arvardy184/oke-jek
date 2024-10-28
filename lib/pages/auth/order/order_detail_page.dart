import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/history/history_controller.dart';
import 'package:okejek_flutter/controller/auth/order/chat_controller.dart';
import 'package:okejek_flutter/controller/auth/order/order_inprogress_controller.dart';
import 'package:okejek_flutter/controller/auth/order/order_receipt_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/pages/auth/bottom_navigation_bar.dart';
import 'package:okejek_flutter/pages/auth/order/chat_page.dart';
import 'package:okejek_flutter/pages/auth/order/receipt_order_page.dart';
import 'package:okejek_flutter/widgets/order/detail/order_detail.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;
  final Map<String, dynamic> driverData;

  OrderDetailPage({required this.order, required this.driverData});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final LandingController landingController = Get.put(LandingController());

  final HistoryController historyController = Get.put(HistoryController());

  final OrderInProgressController orderController = Get.put(OrderInProgressController());
  final ChatController chatController = Get.put(ChatController());
    final OrderReceiptController orderReceiptController = Get.put(OrderReceiptController());
  // final Completer<GoogleMapController> _controller = Completer();

  final PanelController _pc = new PanelController();

  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  late Rx<Order> currentOrder;
  final RxBool isRefreshing = false.obs;
  final RxBool isAutoRefreshEnabled = true.obs;
  Timer? _timer;
  bool hasNavigatedToReceipt = false;

  @override
  void initState() {
    super.initState();
    currentOrder = Rx<Order>(widget.order);
    historyController.initializeOrderMap(currentOrder.value);
    chatController.startPolling(currentOrder.value.id.toString());
    startOrderStatusUpdates();
    //historyController.getNearestDriver();
     ever(currentOrder, (Order order) {
      if (order.status == 3 && !hasNavigatedToReceipt) {
        hasNavigatedToReceipt = true;
        handleOrderCompletion();
      } else if(order.status == -1){
        handleOrderCancellation();
      }
    });
  }

  void handleOrderCancellation() async {
    stopOrderStatusUpdates();
    historyController.driverLocationTimer?.cancel();
    chatController.stopPolling();

 // Show dialog and handle navigation
  Get.defaultDialog(
    title: 'Pesanan Dibatalkan',
    titleStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cancel_outlined,
          color: Colors.red,
          size: 50,
        ),
        SizedBox(height: 16),
        Text(
          'Pesanan Anda telah dibatalkan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Apakah Anda ingin membuat pesanan baru?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    ),
    radius: 10,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    actions: [
      TextButton(
        onPressed: () {
          Get.to(
            () => BottomNavigation(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );
          landingController.changeTab(1); // Go to history tab
          historyController.fetchHistory(); // Refresh history
        },
        child: Text(
          'Tidak',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Get.to(
            () => BottomNavigation(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );
          landingController.changeTab(0); // Go to order tab
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: OkejekTheme.primary_color,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Ya, Pesan Lagi',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );

  }
  void handleOrderCompletion() async {
    // Stop all ongoing processes
    stopOrderStatusUpdates();
    historyController.driverLocationTimer?.cancel();
    chatController.stopPolling();

    // Small delay to ensure clean navigation
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to receipt page
    Get.off(
      () => ReceiptOrderDetail(order: currentOrder.value),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }


  void startOrderStatusUpdates() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      refreshOrderStatus();
    });
  }

  void stopOrderStatusUpdates() {
    _timer?.cancel();
    _timer = null;
  }

Future<void> refreshOrderStatus() async {
  if (!mounted) return;
  
  try {
    Order updatedOrder = await orderController.getOrderDetails(currentOrder.value.id);
    if (updatedOrder.status != currentOrder.value.status) {
      currentOrder.value = updatedOrder;
      historyController.updateDriverLocation(updatedOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getStatusUpdateMessage(updatedOrder.status)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            backgroundColor: _getStatusColor(updatedOrder.status),
          ),
        );
      }
    }
  } catch (e) {
    print('Error refreshing order status: $e');
    // Optionally show error message to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status pesanan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  void dispose() {
    stopOrderStatusUpdates();
    historyController.driverLocationTimer?.cancel();
    chatController.stopPolling();
    super.dispose();
  }

  void startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      refreshOrderStatus();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }


String _getStatusUpdateMessage(int status) {
    switch (status) {
      case 0:
        return 'Mencari driver terdekat...';
      case 1:
        return 'Driver sedang menuju lokasi penjemputan';
      case 2:
        return 'Driver dalam perjalanan menuju tujuan';
      case 3:
        return 'Pesanan telah selesai';
      case 10:
        return 'Menunggu konfirmasi merchant';
      case -1:
        return 'Pesanan dibatalkan';
      default:
        return 'Status pesanan berubah';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 3:
        return Colors.green;
      case -1:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

// Future<void> refreshOrderDetails()async{
//   if(isRefreshing.value) return;

//   isRefreshing.value = true;
//   try{
//     Order updateOrder = await orderController.getOrderDetails(currentOrder.value.id);
//   }
// }
  @override
  Widget build(BuildContext context) {
    print("di order detail page ${historyController.driverLocation}");
      print("cek total pembayaran ${currentOrder.value.payment?.amount}");
    double lat = double.parse(currentOrder.value.originLatlng.split(",")[0]);
    double lng = double.parse(currentOrder.value.originLatlng.split(",")[1]);

    final CameraPosition _kInitialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
    );
    return WillPopScope(
      onWillPop: () async {
        if (currentOrder.value.status == 3) {
          Get.off(() => ReceiptOrderDetail(order: currentOrder.value));
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              SlidingUpPanel(
                controller: _pc,
                minHeight: Get.height * 0.4,
                maxHeight: Get.height * 0.85,
                isDraggable: false,
                body: Obx(() => GoogleMap(
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          historyController.driverLat.value != 0
                              ? historyController.driverLat.value
                              : double.parse(currentOrder.value.originLatlng.split(",")[0]),
                          historyController.driverLng.value != 0
                              ? historyController.driverLng.value
                              : double.parse(currentOrder.value.originLatlng.split(",")[1]),
                        ),
                        zoom: 15.0,
                      ),
                      markers: historyController.markers,
                      onMapCreated: (GoogleMapController controller) {
                        if (!historyController.mapController.isCompleted) {
                          historyController.mapController.complete(controller);
                        }
                      },
                    )),
                panel: slidingPanel(orderController, context),
              ),
              Positioned(
                top: 10,
                left: 0,
                child: GestureDetector(
                  // onTap: () => Get.back(),
                  onTap: () {
                    // Navigate back to BottomNavigation
                    Get.off(() => BottomNavigation(), transition: Transition.fadeIn);
                    // Get.back();
      
                    // Change tab, reset controller, fetch history, and reset filter
                    landingController.changeTab(1);
                    // historyController.resetController();
                    //  historyController.fetchHistory();
                    // historyController.resetFilter();
                  },
                  child: Container(
                    height: SizeConfig.blockSizeHorizontal * 10,
                    width: SizeConfig.blockSizeVertical * 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.5),
                      //     spreadRadius: 1,
                      //     blurRadius: 2,
                      //     offset: Offset(0, 3), // changes position of shadow
                      //   ),
                      // ],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: OkejekTheme.primary_color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget slidingPanel(OrderInProgressController orderController, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      
      ),
      width: Get.width,
      height: Get.height,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: Obx(
            () => ListView(
              physics: orderController.showMore.value ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _buildOrderTypeAndStatus(orderController),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTimeline(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                if (currentOrder.value.status != 0) _buildContactButtons(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildShowMoreButton(orderController),
                Divider(),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                Obx(() => orderController.showMore.value
                    ? OrderDetail(order: currentOrder.value, driverData: widget.driverData)
                    : Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeAndStatus(OrderInProgressController orderController) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
    children: [
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderTypeIcon(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderTypeText(),
                  SizedBox(height: 8),
                  _buildOrderStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 12),
      _buildPriceText(),
    ],
  );
}

Widget _buildOrderTypeText() {
  return Text(
    _getOrderTypeName(currentOrder.value.typeAsInt),
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _buildPriceText() {
  return Container(
    constraints: BoxConstraints(maxWidth: Get.width * 0.3),
    child: Text(
      currentOrder.value.payment == null ? '-' : 
      currencyFormatter.format(currentOrder.value.payment!.amount),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

String _getOrderTypeName(dynamic type) {
  if (type is String) {
    type = int.tryParse(type) ?? -1;
  }
  
  switch (type) {
    case 0:
      return 'OkeRide';
    case 1:
      return 'Kurir';
    case 2:
      return 'Belanja';
    case 3:
      return 'Oke Food';
    case 4:
      return 'Oke Car';
    case 100:
      return 'Oke Mart';
    case 102:
      return 'Ojek Roda 3';
    case 20:
      return 'Oke Rental';
    default:
      return 'Pengantaran';
  }
}

  Widget _buildTimeline() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connected(
        itemCount: 2,
        nodePositionBuilder: (context, index) => 0.0,
        connectorBuilder: (context, index, type) {
          return SizedBox(
            height: SizeConfig.safeBlockHorizontal * 10 / 3.6,
            child: DashedLineConnector(
              color: Colors.grey[300],
            ),
          );
        },

        // text location
        contentsBuilder: (context, index) {
          return index == 0
              ? Padding(
                  padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 8 / 3.6),
                  child: Text(
                    currentOrder.value.originAddress.isEmpty ? '-' : currentOrder.value.originAddress,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 11 / 3.6,
                      color: Colors.black,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 8 / 3.6),
                  child: Text(
                    currentOrder.value.destinationAddress.isEmpty ? '-' : currentOrder.value.destinationAddress,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 11 / 3.6,
                      color: Colors.black,
                    ),
                  ),
                );
        },
        // icon location
        indicatorBuilder: (context, index) {
          return index == 0
              ? Container(
                  height: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                  width: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                  margin: EdgeInsets.only(
                      bottom: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                      right: SizeConfig.safeBlockHorizontal * 10 / 3.6),
                  child: Icon(
                    Icons.store,
                    color: OkejekTheme.primary_color,
                  ),
                )
              : Container(
                  height: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                  width: SizeConfig.safeBlockHorizontal * 15 / 3.6,
                  margin: EdgeInsets.only(
                      bottom: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                      right: SizeConfig.safeBlockHorizontal * 10 / 3.6),
                  child: Icon(
                    Icons.pin_drop_outlined,
                    color: OkejekTheme.primary_color,
                  ),
                );
        },
      ),
    );
  }

  Widget _buildOrderTypeIcon() {
    return Container(
      height: SizeConfig.safeBlockVertical * 30 / 3,
      width: SizeConfig.safeBlockHorizontal * 30 / 3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: currentOrder.value.typeAsInt == 0 || currentOrder.value.typeAsInt == "0"
              ? AssetImage('assets/icons/10-2021/ride.png')
              : currentOrder.value.typeAsInt == 1 || currentOrder.value.typeAsInt == "1"
                  ? AssetImage('assets/icons/10-2021/courier.png')
                  : currentOrder.value.typeAsInt == 2 || currentOrder.value.typeAsInt == "2"
                      ? AssetImage('assets/icons/10-2021/shopping.png')
                      : currentOrder.value.typeAsInt == 3 || currentOrder.value.typeAsInt == "3"
                          ? AssetImage('assets/icons/10-2021/food.png')
                          : currentOrder.value.typeAsInt == 4 || currentOrder.value.typeAsInt == "4"
                              ? AssetImage('assets/icons/10-2021/car.png')
                              : currentOrder.value.typeAsInt == 100 || currentOrder.value.typeAsInt == "100"
                                  ? AssetImage('assets/icons/10-2021/mart.png')
                                  : currentOrder.value.typeAsInt == 102 || currentOrder.value.typeAsInt == "102"
                                      ? AssetImage('assets/icons/10-2021/trike.png')
                                      : currentOrder.value.typeAsInt == 20 || currentOrder.value.typeAsInt == "20"
                                          ? AssetImage('assets/icons/10-2021/driver.png')
                                          : AssetImage('assets/icons/10-2021/trike_courier.png'),
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.safeBlockHorizontal * 3,
        vertical: SizeConfig.safeBlockVertical * 0.5,
      ),
      decoration: BoxDecoration(
        color: OkejekTheme.primary_color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getOrderStatusText(currentOrder.value.status),
        style: TextStyle(
          color: OkejekTheme.primary_color,
          fontSize: SizeConfig.safeBlockHorizontal * 3.3,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.phone, color: OkejekTheme.primary_color),
            label: Text('Call', style: TextStyle(color: OkejekTheme.primary_color)),
            onPressed: () => launchUrlString('tel://${currentOrder.value.driver?.phone ?? ''}'),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1.5),
            ),
          ),
        ),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: Text('Chat', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Get.to(() => ChatPage(
                    orderId: currentOrder.value.id.toString(),
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OkejekTheme.primary_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: OkejekTheme.primary_color),
              ),
              padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowMoreButton(OrderInProgressController orderController) {
    return TextButton(
      onPressed: () {
        orderController.showMore.toggle();
        if (orderController.showMore.value) {
          _pc.open();
        } else {
          _pc.close();
        }
      },
      child: Text(
        orderController.showMore.value ? 'Lihat lebih sedikit' : 'Lihat lebih banyak',
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          fontWeight: FontWeight.bold,
          color: OkejekTheme.primary_color,
        ),
      ),
    );
  }

  String _getOrderStatusText(int status) {
    print("status order detail $status");
    switch (status) {
      case 0:
        return 'Sedang Mencari Driver';
      case 1:
        return 'Sedang Menjemput/Membeli';
      case 2:
        return 'Menuju Lokasi';
      case 10:
        return 'Menunggu Merchant';
      case -1:
        return 'Pesanan dibatalkan ';
      default:
        return 'Order Selesai';
    }
  }
}
