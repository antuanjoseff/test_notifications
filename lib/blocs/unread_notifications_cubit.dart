import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/models/models.dart';

class UnreadNotificationsCubit extends Cubit<UnreadNotificationsModel> {
  UnreadNotificationsCubit(UnreadNotificationsModel state) : super(state);

  void setNotifications(UnreadNotificationsModel unread) => emit(unread);
}
