import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  List<Product> _products = [];
  String filterCategory = 'all';
  String _searchQuery = '';
  bool filterLowOnly = false;

  Future<void> loadProducts() async {
    try {
      final url = Uri.parse(ApiConfig.productsEndpoint);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _products = data.map((e) => Product.fromMap(e)).toList();
        await _save();
        emit(ProductsLoaded(List.from(_products)));
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString('products');
        if (data != null) {
          final List<dynamic> list = jsonDecode(data);
          _products = list.map((e) => Product.fromMap(e)).toList();
        }
        emit(ProductsLoaded(List.from(_products)));
      }
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('products');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _products = list.map((e) => Product.fromMap(e)).toList();
      }
      emit(ProductsLoaded(List.from(_products)));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_products.map((e) => e.toMap()).toList());
    await prefs.setString('products', data);
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _save();
    _emitFiltered();
  }

  Future<void> updateProduct(Product product) async {
    _products = _products.map((p) => p.id == product.id ? product : p).toList();
    await _save();
    _emitFiltered();
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _save();
    _emitFiltered();
  }

  Future<void> addDummyProducts() async {
    _products = [
      Product(
        id: '${DateTime.now().millisecondsSinceEpoch}1',
        name: 'تيشيرت رجالي قطن',
        price: 150.0,
        quantity: 30,
        category: 'ملابس',
        alertThreshold: 5,
        notes: 'ألوان متعددة',
      ),
      Product(
        id: '${DateTime.now().millisecondsSinceEpoch}2',
        name: 'بنطلون جينز',
        price: 250.0,
        quantity: 20,
        category: 'ملابس',
        alertThreshold: 3,
        notes: 'مقاسات متنوعة',
      ),
      Product(
        id: '${DateTime.now().millisecondsSinceEpoch}3',
        name: 'كوتشي رياضي رجالي',
        price: 400.0,
        quantity: 15,
        category: 'كوتشيات',
        alertThreshold: 2,
        notes: 'ماركة أصلية',
      ),
      Product(
        id: '${DateTime.now().millisecondsSinceEpoch}4',
        name: 'كوتشي نسائي أبيض',
        price: 350.0,
        quantity: 18,
        category: 'كوتشيات',
        alertThreshold: 2,
        notes: 'مقاسات من 36 إلى 41',
      ),
      Product(
        id: '${DateTime.now().millisecondsSinceEpoch}5',
        name: 'جاكيت جلد رجالي',
        price: 600.0,
        quantity: 10,
        category: 'ملابس',
        alertThreshold: 2,
        notes: 'جلد طبيعي',
      ),
    ];
    await _save();
    emit(ProductsLoaded(List.from(_products)));
  }

  void setFilterCategory(String category) {
    filterCategory = category;
    _emitFiltered();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void setFilterLowOnly(bool value) {
    filterLowOnly = value;
    _emitFiltered();
  }

  void _emitFiltered() {
    List<Product> filtered = _products;
    if (filterCategory != 'all') {
      filtered = filtered.where((p) => p.category == filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.contains(_searchQuery)).toList();
    }
    if (filterLowOnly) {
      filtered = filtered.where((p) => p.quantity <= p.alertThreshold).toList();
    }
    emit(ProductsLoaded(filtered));
  }
}
