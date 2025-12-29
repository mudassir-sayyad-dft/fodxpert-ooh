import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/video_compression_utils.dart';

/// Dialog to let user select video quality before upload
class VideoQualityDialog extends StatefulWidget {
  final double? originalSizeMB;

  const VideoQualityDialog({super.key, this.originalSizeMB});

  @override
  State<VideoQualityDialog> createState() => _VideoQualityDialogState();
}

class _VideoQualityDialogState extends State<VideoQualityDialog> {
  VideoQuality selectedQuality = VideoQuality.medium;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Video Quality",
              style: textTheme.fs_18_bold,
            ),
            SizedBox(height: 8.h),
            Text(
              "Choose compression quality for faster upload and better compatibility",
              style: textTheme.fs_12_regular.copyWith(color: GetColors.grey2),
            ),
            if (widget.originalSizeMB != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: GetColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16.sp, color: GetColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      "Original: ${widget.originalSizeMB!.toStringAsFixed(1)} MB",
                      style: textTheme.fs_12_medium
                          .copyWith(color: GetColors.primary),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.h),
            ...VideoQuality.values.map((quality) {
              return RadioListTile<VideoQuality>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: quality,
                groupValue: selectedQuality,
                onChanged: (value) {
                  setState(() {
                    selectedQuality = value!;
                  });
                },
                title: Text(
                  quality.name.toUpperCase(),
                  style: textTheme.fs_14_bold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quality.description,
                      style: textTheme.fs_12_regular
                          .copyWith(color: GetColors.grey2),
                    ),
                    Text(
                      "Resolution: ${quality.resolution}",
                      style: textTheme.fs_10_regular
                          .copyWith(color: GetColors.grey3),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: GetColors.grey3),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      "Cancel",
                      style: textTheme.fs_14_medium,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ExpandedButton(
                    onPressed: () => Navigator.of(context).pop(selectedQuality),
                    title: "Continue",
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop('skip'),
                child: Text(
                  "Skip compression (not recommended)",
                  style: textTheme.fs_12_regular.copyWith(
                    color: GetColors.grey2,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show video quality selection dialog
/// Returns VideoQuality if user selects, 'skip' if skip compression, null if cancel
Future<dynamic> showVideoQualityDialog(BuildContext context,
    {double? originalSizeMB}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => VideoQualityDialog(originalSizeMB: originalSizeMB),
  );
}
