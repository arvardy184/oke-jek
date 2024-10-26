import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:okejek_flutter/controller/auth/order/chat_controller.dart';
import 'package:okejek_flutter/defaults/okejek_theme.dart';

class ChatPage extends StatefulWidget {
  final String orderId;

  ChatPage({required this.orderId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();


@override
  void initState() {
    super.initState();
    controller.fetchMessages(widget.orderId);
    controller.startPolling(widget.orderId);
  }

  @override
  void dispose() {
    controller.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchMessages(widget.orderId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OkejekTheme.primary_color,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => controller.driver.isNotEmpty
          ? Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(controller.driver['image_url']),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.driver['name'], style: TextStyle(fontSize: 16)),
                    Text(controller.driver['vehicle_plate'], style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            )
          : Text('Chat')
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => controller.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.messages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final isUser = message['type'] == 1;
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(message['content']),
                      ),
                    );
                  },
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      print("klik send ${messageController.text}");
                      controller.sendMessage(widget.orderId, messageController.text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}