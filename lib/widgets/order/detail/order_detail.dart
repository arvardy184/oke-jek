import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:okejek_flutter/controller/auth/order/order_inprogress_controller.dart';
import 'package:okejek_flutter/controller/landing_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';
import 'package:okejek_flutter/models/auth/order_model.dart';
import 'package:okejek_flutter/models/item_model.dart';

class OrderDetail extends StatelessWidget {
  final Order order;
  final Map<String, dynamic> driverData;

  OrderDetail({required this.order, required this.driverData});

  final OrderInProgressController controller = Get.find<OrderInProgressController>();
  final LandingController landingController = Get.put(LandingController());
  final currencyFormatter = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driverData.isNotEmpty && order.status != 0) _buildDriverCard(),
            // const SizedBox(height: 20),
            // _buildOrderStatus(),
            const SizedBox(height: 20),
            if (order.items.isNotEmpty) _buildItemsList(),
            if (order.courier?.id != null) _buildCourierList(),
            const SizedBox(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 20),
            // if (order.status == 0 || order.status == 1)
            _buildCancelButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: OkejekTheme.primary_color, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(driverData['image_url']),
                    radius: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverData['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${driverData['vehicle_brand']} ${driverData['vehicle_color']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        driverData['vehicle_number'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    final statusText = _getStatusText(order.status);
    final statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Barang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                Item item = Item.fromJson(order.items[index]);
                double subTotal = double.parse(item.price) * item.qty.toDouble();
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item.qty}x @ ${currencyFormatter.format(double.parse(item.price))}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormatter.format(subTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCourierList() {
    if (order.courier == null) return SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCourierSection(
              'Pengirim',
              order.courier!.senderName,
              order.courier!.senderPhone,
            ),
            const Divider(height: 24),
            _buildCourierSection(
              'Penerima',
              order.courier!.recipientName,
              order.courier!.recipientPhone,
            ),
            const Divider(height: 24),
            _buildCourierItemDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourierSection(String title, String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.phone_outlined, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              phone,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourierItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Barang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.courier!.itemDetail,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.scale_outlined, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '${order.courier!.weight} kg',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        if (order.courier!.itemAmount > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.attach_money_outlined, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                currencyFormatter.format(order.courier!.itemAmount),
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ],
    );
  }
  Widget _buildOrderSummary() {
    print("data diskon ${order.discount}");
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Ongkir', double.parse(order.originalFee.toString())),
            if (order.items.isNotEmpty) _buildSummaryRow('Subtotal Belanja', double.parse(order.totalShopping)),
            if (order.discount > 0) _buildSummaryRow('Diskon', order.discount.toDouble(), isDiscount: true),
            const Divider(height: 32),
            _buildSummaryRow(
              'Total',
              order.payment?.amount.toDouble() ?? 0,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : null,
            ),
          ),
          Text(
            isDiscount ? '- ${currencyFormatter.format(amount)}' : currencyFormatter.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => showAlertDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: OkejekTheme.primary_color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Batalkan Pesanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void showAlertDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Batalkan Pesanan'),
        content: const Text(
          'Kamu yakin ingin membatalkan pesanan ini?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Tidak',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.cancelOrder(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: OkejekTheme.primary_color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Menunggu Konfirmasi';
      case 1:
        return 'Mencari Driver';
      case 2:
        return 'Driver Dalam Perjalanan';
      case 3:
        return 'Pesanan Selesai';
      case 4:
        return 'Pesanan Dibatalkan';
      case -1:
        return 'Menunggu Konfirmasi';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
      case 1:
        return OkejekTheme.primary_color;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
