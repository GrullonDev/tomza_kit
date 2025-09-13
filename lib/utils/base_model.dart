import 'package:flutter/material.dart';

import 'package:dartz/dartz.dart';

import 'package:tomza_kit/core/network/failures.dart';
import 'package:tomza_kit/utils/error.dart';
import 'package:tomza_kit/utils/resource.dart';

abstract class BaseBloc<T> extends ChangeNotifier {
  /// Current resource state.
  Resource<T> resource = Resource<T>.initial();

  bool _isDisposed = false;
  int _runCycle = 0; // identifica la última operación run lanzada
  BuildContext? _attachedContext; // contexto opcional para notificaciones UI
  bool _autoNotifyErrors = true; // si se muestran automáticamente los errores

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get isDisposed => _isDisposed;

  /// Adjunta un contexto para permitir mostrar snackbars de error automáticamente.
  /// Puede llamarse desde initState de un widget que consume el bloc.
  void attachContext(BuildContext context, {bool autoNotifyErrors = true}) {
    _attachedContext = context;
    _autoNotifyErrors = autoNotifyErrors;
  }

  void detachContext() {
    _attachedContext = null;
  }

  @protected
  @pragma('vm:prefer-inline')
  void safeNotify() {
    if (_isDisposed) {
      return;
    }
    try {
      notifyListeners();
    } catch (_) {
      /* ignore notify after dispose race */
    }
  }

  /// Sets loading state and notifies listeners (si no está disposed).
  @protected
  void setLoading() {
    resource = Resource<T>.loading();
    safeNotify();
  }

  /// Sets success state and notifies listeners (si no está disposed).
  @protected
  void setSuccess(T data) {
    resource = Resource<T>.success(data);
    safeNotify();
  }

  /// Sets failure state and notifies listeners (si no está disposed).
  @protected
  void setError(Failure failure) {
    resource = Resource<T>.failure(failure);
    safeNotify();
    if (_attachedContext != null && _autoNotifyErrors) {
      // Mostrar snackbar si hay contexto adjunto
      ErrorNotifier.showFailure(_attachedContext!, failure);
    }
  }

  /// Ejecuta una operación async controlando estados y evitando notificar tras dispose.
  Future<void> run(
    Future<Either<Failure, T>> Function() operation, {
    void Function(T data)? onSuccess,
  }) async {
    final int cycle = ++_runCycle; // marca este ciclo
    setLoading();
    final Either<Failure, T> result = await operation();
    if (_isDisposed || cycle != _runCycle) {
      return; // otro run más reciente o disposed
    }
    result.fold(setError, (T data) {
      if (_isDisposed) {
        return;
      }
      setSuccess(data);
      if (onSuccess != null) {
        onSuccess(data);
      }
    });
  }
}
