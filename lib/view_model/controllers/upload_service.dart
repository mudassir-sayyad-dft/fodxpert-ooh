import 'dart:async';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:get/get.dart';

/// Represents the state of a single upload
class UploadTask {
  final String id;
  final String fileName;
  final String screenName;
  final String screenId;
  UploadState state;
  int progress; // 0-100
  String? error;
  AdsModel? result;
  DateTime startTime;
  bool showTimeoutWarning;

  UploadTask({
    required this.id,
    required this.fileName,
    required this.screenName,
    required this.screenId,
    this.state = UploadState.pending,
    this.progress = 0,
    this.error,
    this.result,
    this.showTimeoutWarning = false,
  }) : startTime = DateTime.now();

  /// Check if upload has been running longer than timeout threshold
  bool isLongRunning() {
    const timeoutDuration = Duration(seconds: 15);
    return DateTime.now().difference(startTime) > timeoutDuration;
  }

  /// Get estimated remaining time (5-7 minutes)
  String getEstimatedTime() {
    return "5-7 minutes";
  }
}

enum UploadState { pending, uploading, polling, completed, failed }

/// Service to manage background uploads with status tracking and notifications
class UploadService extends GetxService {
  final RxMap<String, UploadTask> uploadTasks = <String, UploadTask>{}.obs;
  final RxList<String> failedUploads = <String>[].obs;

  late Timer _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const Duration _timeoutCheckInterval = Duration(seconds: 2);

  @override
  void onInit() {
    super.onInit();
    _startPolling();
    _startTimeoutCheck();
  }

  /// Create a new upload task
  String createUploadTask({
    required String fileName,
    required String screenName,
    required String screenId,
  }) {
    final uploadId = _generateUploadId();
    final task = UploadTask(
      id: uploadId,
      fileName: fileName,
      screenName: screenName,
      screenId: screenId,
    );
    uploadTasks[uploadId] = task;
    return uploadId;
  }

  /// Update upload progress
  void updateProgress(String uploadId, int progress) {
    if (uploadTasks.containsKey(uploadId)) {
      uploadTasks[uploadId]!.progress = progress;
      uploadTasks.refresh();
    }
  }

  /// Update upload state
  void updateState(String uploadId, UploadState state) {
    if (uploadTasks.containsKey(uploadId)) {
      uploadTasks[uploadId]!.state = state;
      uploadTasks.refresh();
    }
  }

  /// Mark upload as completed successfully
  void markCompleted(String uploadId, AdsModel result) {
    if (uploadTasks.containsKey(uploadId)) {
      uploadTasks[uploadId]!.state = UploadState.completed;
      uploadTasks[uploadId]!.progress = 100;
      uploadTasks[uploadId]!.result = result;
      uploadTasks.refresh();

      // Remove from failed list if it was there
      failedUploads.remove(uploadId);
    }
  }

  /// Mark upload as failed
  void markFailed(String uploadId, String errorMessage) {
    if (uploadTasks.containsKey(uploadId)) {
      uploadTasks[uploadId]!.state = UploadState.failed;
      uploadTasks[uploadId]!.error = errorMessage;
      uploadTasks.refresh();

      if (!failedUploads.contains(uploadId)) {
        failedUploads.add(uploadId);
      }
    }
  }

  /// Get upload task by ID
  UploadTask? getUploadTask(String uploadId) {
    return uploadTasks[uploadId];
  }

  /// Get all active uploads (not completed or failed)
  List<UploadTask> getActiveUploads() {
    return uploadTasks.values
        .where((task) =>
            task.state != UploadState.completed &&
            task.state != UploadState.failed)
        .toList();
  }

  /// Get all completed uploads for a screen
  List<UploadTask> getCompletedUploads(String screenId) {
    return uploadTasks.values
        .where((task) =>
            task.screenId == screenId && task.state == UploadState.completed)
        .toList();
  }

  /// Remove upload task from tracking (cleanup after showing result)
  void removeUploadTask(String uploadId) {
    uploadTasks.remove(uploadId);
    failedUploads.remove(uploadId);
  }

  /// Start polling for upload status changes
  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      // Polling logic is handled by the controller
      // This timer exists to trigger periodic status checks
    });
  }

  /// Check for uploads that are taking too long and show timeout warning
  void _startTimeoutCheck() {
    Timer.periodic(_timeoutCheckInterval, (_) {
      for (var task in uploadTasks.values) {
        if (task.state == UploadState.uploading ||
            task.state == UploadState.polling) {
          if (task.isLongRunning() && !task.showTimeoutWarning) {
            task.showTimeoutWarning = true;
            uploadTasks.refresh();
          }
        }
      }
    });
  }

  /// Generate unique upload ID
  String _generateUploadId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
  }

  /// Clear completed and failed uploads for a screen
  void clearCompletedUploads(String screenId) {
    uploadTasks.removeWhere((key, task) =>
        task.screenId == screenId &&
        (task.state == UploadState.completed ||
            task.state == UploadState.failed));
    failedUploads.clear();
  }

  @override
  void onClose() {
    _pollingTimer.cancel();
    super.onClose();
  }
}
