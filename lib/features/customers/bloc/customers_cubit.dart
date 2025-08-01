import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/customer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  CustomersCubit() : super(CustomersInitial());

  List<Customer> _customers = [];
  String filterType = 'all'; // all, customer, supplier
  String filterCategory = 'all'; // all, منتظم, متأخر, VIP
  String _searchQuery = '';

  Future<void> loadCustomers() async {
    final url = Uri.parse(ApiConfig.customersEndpoint);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _customers = data.map((e) => Customer.fromMap(e)).toList();
      emit(CustomersLoaded(List.from(_customers)));
    } else {
      emit(CustomersLoaded([]));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_customers.map((e) => e.toMap()).toList());
    await prefs.setString('customers', data);
  }

  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _save();
    emit(CustomersLoaded(List.from(_customers)));
  }

  Future<void> updateCustomer(Customer customer) async {
    _customers =
        _customers.map((c) => c.id == customer.id ? customer : c).toList();
    await _save();
    emit(CustomersLoaded(List.from(_customers)));
  }

  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    await _save();
    emit(CustomersLoaded(List.from(_customers)));
  }

  Future<List<Map<String, dynamic>>> getLoyaltyLog(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('loyalty_log_$customerId');
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(list);
  }

  Future<void> addLoyaltyLog(String customerId, String action, int points,
      {String? note}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('loyalty_log_$customerId');
    final List<dynamic> list = raw == null ? [] : jsonDecode(raw);
    list.add({
      'date': DateTime.now().toIso8601String(),
      'action': action,
      'points': points,
      'note': note ?? '',
    });
    await prefs.setString('loyalty_log_$customerId', jsonEncode(list));
  }

  Future<void> addPoints(String customerId, int points) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx != -1) {
      final c = _customers[idx];
      _customers[idx] = c.copyWith(loyaltyPoints: c.loyaltyPoints + points);
      await _save();
      await addLoyaltyLog(customerId, 'add', points);
      emit(CustomersLoaded(List.from(_customers)));
    }
  }

  Future<void> deductPoints(String customerId, int points) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx != -1) {
      final c = _customers[idx];
      _customers[idx] = c.copyWith(
          loyaltyPoints: (c.loyaltyPoints - points).clamp(0, 999999));
      await _save();
      await addLoyaltyLog(customerId, 'deduct', points);
      emit(CustomersLoaded(List.from(_customers)));
    }
  }

  void setFilterType(String type) {
    filterType = type;
    _emitFiltered();
  }

  void setFilterCategory(String category) {
    filterCategory = category;
    _emitFiltered();
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void _emitFiltered() {
    List<Customer> filtered = _customers;
    if (filterType != 'all') {
      filtered = filtered.where((c) => c.type == filterType).toList();
    }
    if (filterCategory != 'all') {
      filtered = filtered.where((c) => c.category == filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) => c.name.contains(_searchQuery)).toList();
    }
    emit(CustomersLoaded(filtered));
  }
}
