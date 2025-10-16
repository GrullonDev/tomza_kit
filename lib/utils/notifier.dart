import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/failures.dart';
import 'package:tomza_kit/utils/error.dart';

/// Top-level convenience functions so consumers can call
/// `showFailure`, `showInfo` and `showSuccess` directly without
/// referencing the `ErrorNotifier` class.
///
/// All functions accept an optional [BuildContext]. If `null`, the
/// library will try to use the configured `ErrorNotifier.scaffoldMessengerKey`
/// or `ErrorNotifier.showCallback` (see `ErrorNotifier.initialize`).
void showFailure(BuildContext? context, Failure failure) =>
    ErrorNotifier.showFailure(failure);

void showInfo(BuildContext? context, String message) =>
    ErrorNotifier.showInfo(message);

void showSuccess(BuildContext? context, String message) =>
    ErrorNotifier.showSuccess(message);

void showError(BuildContext? context, String message) =>
    ErrorNotifier.showError(message);
