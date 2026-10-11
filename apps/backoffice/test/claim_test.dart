import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/claims/domain/claim.dart';

Claim claimAt(DateTime createdAt) => Claim(
      id: 'C',
      orderId: 'D-1',
      channel: DeliveryChannel.didi,
      reason: ClaimReason.quality,
      amount: 10,
      createdAt: createdAt,
    );

void main() {
  final created = DateTime(2026, 1, 5, 12);

  test('urgencia ok con holgura', () {
    expect(claimAt(created).urgencyAt(created.add(const Duration(hours: 1))), ClaimUrgency.ok);
  });

  test('urgencia warning y critical', () {
    expect(claimAt(created).urgencyAt(created.add(const Duration(hours: 18))), ClaimUrgency.warning);
    expect(claimAt(created).urgencyAt(created.add(const Duration(hours: 21))), ClaimUrgency.critical);
  });

  test('urgencia expirada', () {
    expect(claimAt(created).urgencyAt(created.add(const Duration(hours: 25))), ClaimUrgency.expired);
  });

  test('countdown formatea y expira', () {
    expect(claimAt(created).countdown(created), '24:00:00');
    expect(claimAt(created).countdown(created.add(const Duration(hours: 23))), '01:00:00');
    expect(claimAt(created).countdown(created.add(const Duration(hours: 25))), 'Expirado');
  });
}
