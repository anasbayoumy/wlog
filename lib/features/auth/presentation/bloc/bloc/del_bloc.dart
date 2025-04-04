import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'del_event.dart';
part 'del_state.dart';

class DelBloc extends Bloc<DelEvent, DelState> {
  DelBloc() : super(DelInitial()) {
    on<DelEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
