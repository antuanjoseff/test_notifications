import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/User.dart';

class UserCubit extends Cubit<User> {
  UserCubit(User state) : super(state);

  void setUser(User user) => emit(user);

  void logout() => emit(User());
}
