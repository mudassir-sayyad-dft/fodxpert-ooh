import 'package:flutter/material.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer/Skeleton loader for displaying uploading ads
class UploadingAdShimmer extends StatelessWidget {
  final String fileName;
  final int? progress; // 0-100, null means indeterminate
  final bool isLongRunning;
  final VoidCallback? onCancel;

  const UploadingAdShimmer({
    Key? key,
    required this.fileName,
    this.progress,
    this.isLongRunning = false,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: GetColors.white,
          border: Border.all(color: GetColors.grey1, width: 1),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer skeleton for thumbnail
            Shimmer.fromColors(
              baseColor: GetColors.grey1,
              highlightColor: GetColors.grey2,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: GetColors.grey1,
                ),
              ),
            ),
            SizedBox(height: 12),

            // File name
            Text(
              fileName.length > 40
                  ? fileName.substring(0, 37) + '...'
                  : fileName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GetColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            // Progress bar
            if (progress != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress! / 100,
                      minHeight: 6,
                      backgroundColor: GetColors.grey1,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GetColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${progress}% uploaded',
                    style: TextStyle(
                      fontSize: 11,
                      color: GetColors.grey2,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: GetColors.grey1,
                    highlightColor: GetColors.grey2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: double.infinity,
                        height: 6,
                        color: GetColors.grey1,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 11,
                      color: GetColors.grey2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

            // Timeout warning
            if (isLongRunning) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFFFFE69C), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFFFA500),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This may take 5-7 minutes to complete',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 8),

            // Cancel button
            if (onCancel != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: GetColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: GetColors.primary,
                      fontSize: 12,
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

/// Shimmer skeleton loader while determining upload state
class UploadPlaceholderShimmer extends StatelessWidget {
  const UploadPlaceholderShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: GetColors.white,
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: GetColors.grey1,
              highlightColor: GetColors.grey2,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: GetColors.grey1,
                ),
              ),
            ),
            SizedBox(height: 12),
            Shimmer.fromColors(
              baseColor: GetColors.grey1,
              highlightColor: GetColors.grey2,
              child: Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: GetColors.grey1,
                ),
              ),
            ),
            SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: GetColors.grey1,
              highlightColor: GetColors.grey2,
              child: Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: GetColors.grey1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
