part of 'users_cubit.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  UsersLoaded(this.users);
}
