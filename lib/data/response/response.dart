// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fodex_new/view_model/enums/enums.dart';

class ApiResponse<T> {
  String? message;
  T? data;
  ApiStatus? status;

  ApiResponse({this.message, this.data, this.status});

  ApiResponse.set() : status = ApiStatus.PENDING;
  ApiResponse.complete({required this.data}) : status = ApiStatus.COMPLETE;
  ApiResponse.error({required this.message}) : status = ApiStatus.ERROR;
  ApiResponse.loading() : status = ApiStatus.LOADING;

  @override
  String toString() =>
      'ApiResponse(message: $message, data: $data, status: $status)';
}
