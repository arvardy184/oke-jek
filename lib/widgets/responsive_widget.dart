import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation, DeviceType deviceType) builder;

  const ResponsiveWidget({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            DeviceType deviceType = _getDeviceType(constraints);
            return builder(context, orientation, deviceType);
          },
        );
      },
    );
  }

  DeviceType _getDeviceType(BoxConstraints constraints) {
    double deviceWidth = constraints.maxWidth;
    if (deviceWidth > 950) return DeviceType.Desktop;
    if (deviceWidth > 600) return DeviceType.Tablet;
    return DeviceType.Mobile;
  }
}

enum DeviceType { Mobile, Tablet, Desktop }