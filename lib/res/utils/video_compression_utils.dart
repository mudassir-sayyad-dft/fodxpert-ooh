import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

/// Video quality presets for compression
enum VideoQuality {
  /// Low quality: 640x360, 500k bitrate, CRF 30
  low('640x360', '500k', 30, 'Low (Faster upload, smaller file)'),

  /// Medium quality: 1280x720, 1500k bitrate, CRF 28
  medium('1280x720', '1500k', 28, 'Medium (Balanced)'),

  /// High quality: 1920x1080, 3000k bitrate, CRF 23
  high('1920x1080', '3000k', 23, 'High (Better quality, larger file)');

  final String resolution;
  final String bitrate;
  final int crf;
  final String description;

  const VideoQuality(this.resolution, this.bitrate, this.crf, this.description);
}

class VideoCompressionUtils {
  /// Compress video file using FFmpeg
  ///
  /// [inputFile] - Original video file
  /// [quality] - Quality preset (low, medium, high)
  /// [onProgress] - Optional callback for progress updates (0-100)
  ///
  /// Returns compressed video file
  static Future<File> compressVideo(
    File inputFile, {
    VideoQuality quality = VideoQuality.medium,
    Function(double progress)? onProgress,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/compressed_$timestamp.mp4';

    // FFmpeg command for compression
    final command = '-i "${inputFile.path}" '
        '-vf "scale=${quality.resolution}:force_original_aspect_ratio=decrease,pad=${quality.resolution}:(ow-iw)/2:(oh-ih)/2" '
        '-c:v libx264 '
        '-crf ${quality.crf} '
        '-preset fast '
        '-b:v ${quality.bitrate} '
        '-c:a aac '
        '-b:a 128k '
        '-movflags +faststart '
        '-y "$outputPath"';

    print('FFmpeg compression command: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        print('Video compressed successfully: ${outputFile.path}');
        return outputFile;
      } else {
        throw Exception('Compressed file not found at: $outputPath');
      }
    } else {
      final output = await session.getOutput();
      throw Exception('Video compression failed: $output');
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Check if file needs compression based on size threshold
  static Future<bool> shouldCompress(File file,
      {double thresholdMB = 50}) async {
    final sizeMB = await getFileSizeMB(file);
    return sizeMB > thresholdMB;
  }

  /// Get video information (resolution, duration, etc.)
  static Future<Map<String, dynamic>> getVideoInfo(File file) async {
    try {
      final command = '-i "${file.path}" -hide_banner';
      final session = await FFmpegKit.execute(command);
      final output = await session.getOutput();

      // Parse output for video info (basic implementation)
      return {
        'path': file.path,
        'size': await getFileSizeMB(file),
        'exists': await file.exists(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
