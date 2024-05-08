import 'package:equatable/equatable.dart';

import 'package:docs/models/models.dart';

class ControllerStateBase extends Equatable {
  const ControllerStateBase({this.error});

  final AppError? error;

  @override
  List<Object?> get props => [error];

  ControllerStateBase copyWith({AppError? error}) =>
      ControllerStateBase(error: error ?? this.error);
}
