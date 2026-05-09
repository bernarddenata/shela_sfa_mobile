import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/repositories/app_state_scope.dart';

class CustomerInfoPage extends StatelessWidget {
  const CustomerInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppStateScope.of(context);
    final visit = repository.activeVisit;
    final customer = visit == null
        ? null
        : repository.getCustomerById(visit.customerId);
    final user = repository.activeUser;

    if (visit == null || customer == null || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Info')),
        body: const Center(
          child: Text('Please check in before opening store information.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Info')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Address', value: customer.address),
                    _InfoRow(label: 'Phone', value: customer.phone),
                    _InfoRow(label: 'Status', value: customer.status),
                    _InfoRow(
                      label: 'Last Visit',
                      value: DateFormatters.compactDate(customer.lastVisit),
                    ),
                    _InfoRow(
                      label: 'Last Order',
                      value: CurrencyFormatters.rupiah(
                        customer.lastOrderAmount,
                      ),
                    ),
                    _InfoRow(label: 'Branch', value: user.branchName),
                    _InfoRow(
                      label: 'Customer Type',
                      value: customer.customerType,
                    ),
                    _InfoRow(
                      label: 'Credit Limit',
                      value: CurrencyFormatters.rupiah(customer.creditLimit),
                    ),
                    _InfoRow(
                      label: 'Outstanding',
                      value: CurrencyFormatters.rupiah(
                        customer.outstandingAmount,
                      ),
                    ),
                    _InfoRow(
                      label: 'Payment Status',
                      value: customer.paymentStatus,
                    ),
                    _InfoRow(label: 'Notes', value: customer.notes),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
