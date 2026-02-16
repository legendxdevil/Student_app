import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:student_app/core/services/storage_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetDarkMode extends ThemeEvent {
  final bool isDarkMode;
  const SetDarkMode(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

// States
class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({this.isDarkMode = false});

  @override
  List<Object> get props => [isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetDarkMode>(_onSetDarkMode);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = StorageService.instance.getBool('isDarkMode') ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final newState = !state.isDarkMode;
    StorageService.instance.setBool('isDarkMode', newState);
    emit(ThemeState(isDarkMode: newState));
  }

  void _onSetDarkMode(SetDarkMode event, Emitter<ThemeState> emit) {
    StorageService.instance.setBool('isDarkMode', event.isDarkMode);
    emit(ThemeState(isDarkMode: event.isDarkMode));
  }
}
