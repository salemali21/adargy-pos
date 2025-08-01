part of 'customers_cubit.dart';

abstract class CustomersState {}

class CustomersInitial extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  CustomersLoaded(this.customers);
}
