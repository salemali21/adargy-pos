part of 'invoices_cubit.dart';

abstract class InvoicesState {}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<Invoice> invoices;
  InvoicesLoaded(this.invoices);
}
