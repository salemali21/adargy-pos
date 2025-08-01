import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_cubit.dart';
import '../models/product.dart';
import '../../../core/widgets/main_scaffold.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onNavTap(int index) {
    const routes = [
      '/customers',
      '/products',
      '/sale',
      '/invoices',
      '/inventory',
      '/reports',
      '/support',
      '/settings',
    ];
    if (index != 1) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'المنتجات',
      currentIndex: 1,
      onTap: _onNavTap,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => const AddProductDialog(),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'إضافة منتج جديد',
        ),
        body: Column(
          children: [
            BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                print(
                    'Products state: ${state.runtimeType}, products count: ${state is ProductsLoaded ? state.products.length : 0}');
                if (state is ProductsLoaded && state.products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('إدخال منتجات ملابس وكوتشيات تلقائيًا'),
                      onPressed: () {
                        context.read<ProductsCubit>().addDummyProducts();
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        final categories = <String>{'all'};
                        if (state is ProductsLoaded) {
                          for (final p in state.products) {
                            if (p.category != null && p.category!.isNotEmpty) {
                              categories.add(p.category ?? '');
                            }
                          }
                        }
                        return DropdownButton<String>(
                          value: context.select<ProductsCubit, String>(
                              (c) => c.filterCategory),
                          items: categories
                              .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child:
                                      Text(cat == 'all' ? 'كل الفئات' : cat)))
                              .toList(),
                          onChanged: (v) => context
                              .read<ProductsCubit>()
                              .setFilterCategory(v ?? ''),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'عرض المنتجات الناقصة فقط',
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        final showLow = context.select<ProductsCubit, bool>(
                            (c) => c.filterLowOnly);
                        return Checkbox(
                          value: showLow,
                          onChanged: (v) => context
                              .read<ProductsCubit>()
                              .setFilterLowOnly(v ?? false),
                        );
                      },
                    ),
                  ),
                  const Text('ناقص'),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث عن منتج...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'مسح البحث',
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ProductsCubit>()
                                      .searchProducts('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) =>
                          context.read<ProductsCubit>().searchProducts(val),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoaded) {
                    final filtered = state.products.where((p) {
                      final matchesSearch = p.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                      final matchesCategory =
                          context.select<ProductsCubit, String>(
                                      (c) => c.filterCategory) ==
                                  'all' ||
                              p.category ==
                                  context.select<ProductsCubit, String>(
                                      (c) => c.filterCategory);
                      final isLow = p.quantity <= p.alertThreshold;
                      final matchesLowOnly = context
                          .select<ProductsCubit, bool>((c) => c.filterLowOnly);

                      return matchesSearch &&
                          matchesCategory &&
                          (matchesLowOnly ? isLow : true);
                    }).toList();

                    return filtered.isEmpty
                        ? const Center(child: Text('لا يوجد منتجات'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              final isLow = p.quantity <= p.alertThreshold;
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        isLow ? Colors.red : Colors.green,
                                    child: const Icon(Icons.inventory,
                                        color: Colors.white),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (isLow)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'ناقص',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      const Text('السعر: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(p.price.toStringAsFixed(2),
                                          style: const TextStyle(
                                              color: Colors.blue)),
                                      const SizedBox(width: 16),
                                      const Text('الكمية: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(p.quantity.toString(),
                                          style: TextStyle(
                                              color: isLow
                                                  ? Colors.red
                                                  : Colors.green)),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (action) async {
                                      if (action == 'edit') {
                                        await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AddProductDialog(editProduct: p),
                                        );
                                      } else if (action == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: Text(
                                                'هل أنت متأكد من حذف ${p.name}؟'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('إلغاء'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('حذف'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          context
                                              .read<ProductsCubit>()
                                              .deleteProduct(p.id);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'edit', child: Text('تعديل')),
                                      const PopupMenuItem(
                                          value: 'delete', child: Text('حذف')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Product? editProduct;
  const AddProductDialog({super.key, this.editProduct});
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _priceController;
  TextEditingController? _quantityController;
  TextEditingController? _categoryController;
  TextEditingController? _alertThresholdController;
  TextEditingController? _notesController;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _quantityController =
        TextEditingController(text: p?.quantity.toString() ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _alertThresholdController =
        TextEditingController(text: p?.alertThreshold.toString() ?? '1');
    _notesController = TextEditingController(text: p?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.editProduct == null ? 'إضافة منتج جديد' : 'تعديل منتج'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'الفئة'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alertThresholdController,
                decoration:
                    const InputDecoration(labelText: 'حد التنبيه (كمية)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final product = Product(
                id: widget.editProduct?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController!.text,
                price: double.tryParse(_priceController!.text) ?? 0,
                quantity: int.tryParse(_quantityController!.text) ?? 0,
                category: _categoryController!.text.isEmpty
                    ? null
                    : _categoryController!.text,
                alertThreshold:
                    int.tryParse(_alertThresholdController!.text) ?? 1,
                notes: _notesController!.text,
              );
              if (widget.editProduct == null) {
                context.read<ProductsCubit>().addProduct(product);
              } else {
                context.read<ProductsCubit>().updateProduct(product);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
