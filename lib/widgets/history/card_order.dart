import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/history/history_controller.dart';
import 'package:okejek_flutter/controller/auth/order/order_inprogress_controller.dart';
import 'package:okejek_flutter/controller/auth/order/order_receipt_controller.dart';
import 'package:okejek_flutter/defaults/size_config.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/pages/auth/order/order_detail_page.dart';
import 'package:okejek_flutter/pages/auth/order/receipt_order_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

/// Menampilkan pesanan dalam bentuk card
class CardOrder extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);
  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  final HistoryController historyController = Get.find();
  final OrderInProgressController orderInProgressController = Get.put(OrderInProgressController());
  final OrderReceiptController orderReceiptController = Get.put(OrderReceiptController());

  CardOrder({
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    String dateCreated = dateFormat.format(order.createdAt);
     
    return GestureDetector(
      onTap: () {
        orderInProgressController.showMore.value = false;
        orderReceiptController.resetController();

        order.status == 3
            ? PersistentNavBarNavigator.pushNewScreen(context, screen: ReceiptOrderDetail(order: order), withNavBar: false)
            : order.status == 100 || order.status == 2 || order.status == 1 || order.status == 0 || order.status == 10
                ? PersistentNavBarNavigator.pushNewScreen(context, screen: OrderDetailPage(order: order,
              driverData: order.driver != null ? order.driver!.toJson() : {},
                ), withNavBar: false).then((value) {
                    historyController.resetController();
                    historyController.fetchHistory();
                  })
                : print('do nothing ${order.status}' );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: SizeConfig.safeBlockHorizontal * 20 / 3.6),
        elevation: 3.0,
        child: Container(
          margin: EdgeInsets.all(10),
          height: Get.height * 0.14,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: SizeConfig.safeBlockVertical * 60 / 7.56,
                width: SizeConfig.safeBlockHorizontal * 60 / 3.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: order.typeAsInt == 0
                        ? AssetImage('assets/icons/10-2021/ride.png')
                        : order.typeAsInt == 1
                            ? AssetImage('assets/icons/10-2021/courier.png')
                            : order.typeAsInt == 2
                                ? AssetImage('assets/icons/10-2021/shopping.png')
                                : order.typeAsInt == 3
                                    ? AssetImage('assets/icons/10-2021/food.png')
                                    : order.typeAsInt == 4
                                        ? AssetImage('assets/icons/10-2021/car.png')
                                        : order.typeAsInt == 100
                                            ? AssetImage('assets/icons/10-2021/mart.png')
                                            : order.typeAsInt == 102
                                                ? AssetImage('assets/icons/10-2021/trike.png')
                                                : order.typeAsInt == 20
                                                    ? AssetImage('assets/icons/10-2021/driver.png')
                                                    : AssetImage('assets/icons/10-2021/trike_courier.png'),
                  ),
                ),
              ),
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 20 / 3.6,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: SizeConfig.safeBlockHorizontal * 20 / 3.6,
                            color: Colors.black45,
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                          ),
                          Flexible(
                            child: Text(
                              dateCreated,
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Icon(
                            Icons.pin_drop_outlined,
                            size: SizeConfig.safeBlockHorizontal * 20 / 3.6,
                            color: Colors.black45,
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                          ),
                          Flexible(
                            child: Text(
                              order.destinationAddress,
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                                color: Colors.black54,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.red,
                      width: Get.width * 0.65,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              order.payment == null ? '-' : currencyFormatter.format(order.payment!.amount),
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 12 / 3.6,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            order.status == 100
                                ? 'Pending Payment'
                                : order.status == 10
                                    ? 'Pending Merchant'
                                    : order.status == 3
                                        ? 'Selesai'
                                        : order.status == 2
                                            ? 'Dalam Perjalanan'
                                            : order.status == 1
                                                ? 'Menuju lokasi'
                                                : order.status == 0
                                                    ? 'Pending'
                                                    : 'Dibatalkan',
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 10 / 3.6,
                              fontWeight: FontWeight.bold,
                              color: order.status == 3
                                  ? Colors.green
                                  : order.status == -1
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ),
                        ],
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
