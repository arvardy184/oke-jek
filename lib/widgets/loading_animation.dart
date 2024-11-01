import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:okejek_flutter/defaults/size_config.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     
    return Transform.scale(
      scale: 0.2,
      child: SizedBox(
        height: SizeConfig.safeBlockHorizontal * 200 / 3.6,
        width: SizeConfig.safeBlockHorizontal * 200 / 3.6,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScaleParty,
          strokeWidth: 10.0,
          colors: [
           Colors.deepPurpleAccent,
            Color(0XFF3c2782),
          ],
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.black,
        ),
      ),
    );
  }
}

class LoadinBallSyncAnimation extends StatelessWidget {
  const LoadinBallSyncAnimation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     
    return Transform.scale(
      scale: 0.5,
      child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        strokeWidth: 2,
        colors: [Color(0XFF3c2782)],
      ),
    );
  }
}
