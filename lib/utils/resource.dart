import 'package:tomza_kit/core/network/failures.dart';

enum Status { initial, loading, success, failure }

class Resource<T> {
  const Resource._({required this.status, this.data, this.error});

  factory Resource.initial() => Resource<T>._(status: Status.initial);
  factory Resource.loading() => Resource<T>._(status: Status.loading);
  factory Resource.success(T data) =>
      Resource<T>._(status: Status.success, data: data);
  factory Resource.failure(Failure error) =>
      Resource<T>._(status: Status.failure, error: error);

  final Status status;
  final T? data;
  final Failure? error;
}
