import 'package:flutter/widgets.dart';
import 'package:all_in_one/constant/hive_boxes.dart';

class ShowAccountPage extends StatelessWidget {
  const ShowAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(HiveBoxes.accountBox.toMap().toString()),
      ),
    );
  }
}
