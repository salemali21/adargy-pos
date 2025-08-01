import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  List<User> _users = [];
  String _searchQuery = '';

  Future<void> loadUsers() async {
    try {
      final url = Uri.parse(ApiConfig.usersEndpoint);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((e) => User.fromMap(e)).toList();
        await _save();
        emit(UsersLoaded(List.from(_users)));
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString('users');
        if (data != null) {
          final List<dynamic> list = jsonDecode(data);
          _users = list.map((e) => User.fromMap(e)).toList();
        }
        emit(UsersLoaded(List.from(_users)));
      }
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('users');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _users = list.map((e) => User.fromMap(e)).toList();
      }
      emit(UsersLoaded(List.from(_users)));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_users.map((e) => e.toMap()).toList());
    await prefs.setString('users', data);
  }

  Future<void> addUser(User user) async {
    _users.add(user);
    await _save();
    _emitFiltered();
  }

  Future<void> updateUser(User user) async {
    _users = _users.map((u) => u.id == user.id ? user : u).toList();
    await _save();
    _emitFiltered();
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
    await _save();
    _emitFiltered();
  }

  void searchUsers(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void _emitFiltered() {
    List<User> filtered = _users;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) => u.name.contains(_searchQuery)).toList();
    }
    emit(UsersLoaded(filtered));
  }

  Future<void> addActivity(String userId, String activity) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = _users[idx];
      final updated =
          user.copyWith(activityLog: [...user.activityLog, activity]);
      _users[idx] = updated;
      await _save();
      _emitFiltered();
    }
  }

  Future<void> updatePermissions(
      String userId, List<String> permissions) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = _users[idx];
      final updated = user.copyWith(permissions: permissions);
      _users[idx] = updated;
      await _save();
      _emitFiltered();
    }
  }
}
