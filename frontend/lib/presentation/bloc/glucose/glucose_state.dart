
part of 'glucose_bloc.dart';

abstract class GlucoseState extends Equatable {
  const GlucoseState();
  
  @override
  List<Object> get props => [];
}

class GlucoseInitial extends GlucoseState {}

class GlucoseLoading extends GlucoseState {}

class GlucoseLoaded extends GlucoseState {
  final List<GlucoseMeasurement> history;

  const GlucoseLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class GlucoseError extends GlucoseState {
  final String message;

  const GlucoseError(this.message);

  @override
  List<Object> get props => [message];
}

class GlucoseAdding extends GlucoseState {}

class GlucoseAdded extends GlucoseState {}
