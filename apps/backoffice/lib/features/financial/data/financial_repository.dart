import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentStatus { paid, zeroBalance }

class PaymentRow {
  const PaymentRow({
    required this.paymentId,
    required this.storeOrBrand,
    required this.paymentDate,
    required this.salePeriod,
    this.amount,
    required this.status,
  });

  final String paymentId;
  final String storeOrBrand;
  final String paymentDate;
  final String salePeriod;
  final double? amount;
  final PaymentStatus status;
}

class FinancialRepository {
  List<PaymentRow> seed() => const <PaymentRow>[
        PaymentRow(paymentId: '8492270', storeOrBrand: 'Alenka´s Bakery - Proceres', paymentDate: '08/10/2026', salePeriod: '01/10 - 02/10', status: PaymentStatus.zeroBalance),
        PaymentRow(paymentId: '8487363', storeOrBrand: 'KORYTKOWSKI BARANDIARAN JANUSZ KARL', paymentDate: '10/10/2026', salePeriod: '01/10 - 02/10', amount: 416.28, status: PaymentStatus.paid),
        PaymentRow(paymentId: '8484150', storeOrBrand: 'Alenkas - Chorrillos 1', paymentDate: '08/10/2026', salePeriod: '01/10 - 02/10', amount: -3.54, status: PaymentStatus.zeroBalance),
        PaymentRow(paymentId: '8476806', storeOrBrand: 'ROMERO HORMAZABAL ANAHI MARIA', paymentDate: '08/10/2026', salePeriod: '01/10 - 02/10', status: PaymentStatus.zeroBalance),
        PaymentRow(paymentId: '8440874', storeOrBrand: 'KORYTKOWSKI BARANDIARAN JANUSZ KARL', paymentDate: '10/10/2026', salePeriod: '26/09 - 30/09', amount: 726.75, status: PaymentStatus.paid),
        PaymentRow(paymentId: '8403061', storeOrBrand: 'KORYTKOWSKI BARANDIARAN JANUSZ KARL', paymentDate: '05/10/2026', salePeriod: '19/09 - 25/09', amount: 1699.33, status: PaymentStatus.paid),
        PaymentRow(paymentId: '8392855', storeOrBrand: 'ROMERO HORMAZABAL ANAHI MARIA', paymentDate: '05/10/2026', salePeriod: '19/09 - 25/09', amount: 15.48, status: PaymentStatus.paid),
      ];
}

final Provider<FinancialRepository> financialRepositoryProvider =
    Provider<FinancialRepository>((ref) => FinancialRepository());
