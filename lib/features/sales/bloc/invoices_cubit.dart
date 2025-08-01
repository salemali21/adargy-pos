import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/invoice.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
part 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit() : super(InvoicesInitial());

  List<Invoice> _invoices = [];
  String _searchQuery = '';
  String? filterCustomerId;
  String? filterPaymentMethod;
  DateTimeRange? filterDateRange;

  Future<void> loadInvoices() async {
    final url = Uri.parse(ApiConfig.invoicesEndpoint);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _invoices = data.map((e) => Invoice.fromMap(e)).toList();
      emit(InvoicesLoaded(List.from(_invoices)));
    } else {
      emit(InvoicesLoaded([]));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_invoices.map((e) => e.toMap()).toList());
    await prefs.setString('invoices', data);
  }

  Future<void> sendInvoiceToBackend(Invoice invoice) async {
    final url = Uri.parse(ApiConfig.invoicesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toMap()),
    );
    if (response.statusCode != 201) {
      throw Exception('فشل في حفظ الفاتورة على السيرفر');
    }
  }

  @override
  Future<void> addInvoice(Invoice invoice) async {
    await sendInvoiceToBackend(invoice);
    _invoices.add(invoice);
    await _save();
    _emitFiltered();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    _invoices = _invoices.map((i) => i.id == invoice.id ? invoice : i).toList();
    await _save();
    _emitFiltered();
  }

  Future<void> deleteInvoice(String id) async {
    _invoices.removeWhere((i) => i.id == id);
    await _save();
    _emitFiltered();
  }

  Future<void> clearAllInvoices() async {
    _invoices.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('invoices');
    emit(InvoicesLoaded([]));
  }

  Future<void> addDummyInvoices() async {
    _invoices = [
      Invoice(
        id: '${DateTime.now().millisecondsSinceEpoch}1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          InvoiceItem(
            productId: '1',
            name: 'تيشيرت رجالي قطن',
            price: 150.0,
            quantity: 2,
          ),
          InvoiceItem(
            productId: '3',
            name: 'كوتشي رياضي رجالي',
            price: 400.0,
            quantity: 1,
          ),
        ],
        customerId: 'c1',
        customerName: 'أحمد علي',
        total: 700.0,
        discount: 50.0,
        tax: 20.0,
        paymentMethod: 'cash',
        notes: 'فاتورة تجريبية',
      ),
      Invoice(
        id: '${DateTime.now().millisecondsSinceEpoch}2',
        date: DateTime.now(),
        items: [
          InvoiceItem(
            productId: '2',
            name: 'بنطلون جينز',
            price: 250.0,
            quantity: 1,
          ),
          InvoiceItem(
            productId: '4',
            name: 'كوتشي نسائي أبيض',
            price: 350.0,
            quantity: 2,
          ),
        ],
        customerId: 'c2',
        customerName: 'منى محمد',
        total: 950.0,
        discount: 0.0,
        tax: 30.0,
        paymentMethod: 'visa',
        notes: '',
      ),
    ];
    await _save();
    emit(InvoicesLoaded(List.from(_invoices)));
  }

  void searchInvoices(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void setFilterCustomerId(String? id) {
    filterCustomerId = id;
    _emitFiltered();
  }

  void setFilterPaymentMethod(String? method) {
    filterPaymentMethod = method;
    _emitFiltered();
  }

  void setFilterDateRange(DateTimeRange? range) {
    filterDateRange = range;
    _emitFiltered();
  }

  void _emitFiltered() {
    List<Invoice> filtered = _invoices;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((i) => i.customerName?.contains(_searchQuery) ?? false)
          .toList();
    }
    if (filterCustomerId != null) {
      filtered =
          filtered.where((i) => i.customerId == filterCustomerId).toList();
    }
    if (filterPaymentMethod != null) {
      filtered = filtered
          .where((i) => i.paymentMethod == filterPaymentMethod)
          .toList();
    }
    if (filterDateRange != null) {
      filtered = filtered
          .where((i) =>
              i.date.isAfter(
                  filterDateRange!.start.subtract(const Duration(days: 1))) &&
              i.date
                  .isBefore(filterDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }
    emit(InvoicesLoaded(filtered));
  }
}
