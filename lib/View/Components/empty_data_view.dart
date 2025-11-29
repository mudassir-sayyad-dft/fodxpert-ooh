import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/res/icons_and_images.dart';

import '../../main.dart';

class EmptyDataView extends StatelessWidget {
  const EmptyDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          Image.asset(GetImages.no_data),
          Text("No Data Found!", style: textTheme.fs_18_bold),
          // Text("Collection List is Empty", style: textTheme.fs_16_regular),
        ],
      ),
    );
  }
}
