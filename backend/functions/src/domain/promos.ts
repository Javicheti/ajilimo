export type PromoIssueKind = 'off' | 'full_price';

export interface PromoExpectation {
  sku: string;
  title: string;
  /** Debe estar encendido durante toda la operación. */
  shouldBeOn: boolean;
  /** Precio promocional esperado (para detectar venta a precio full). */
  promoPrice?: number;
}

export interface PromoMenuItem {
  sku: string;
  title: string;
  available: boolean;
  price: number;
}

export interface PromoIssue {
  sku: string;
  title: string;
  kind: PromoIssueKind;
  message: string;
}

/**
 * Evalúa promociones/sabores:
 * - `off`: debería estar encendido y no lo está (apagado o suspendido por la app).
 * - `full_price`: se está ofreciendo por encima del precio promocional.
 */
export function evaluatePromos(
  items: PromoMenuItem[],
  expectations: PromoExpectation[],
): PromoIssue[] {
  const bySku = new Map(items.map((item) => [item.sku, item]));
  const issues: PromoIssue[] = [];

  for (const expectation of expectations) {
    const item = bySku.get(expectation.sku);
    if (!item) continue;

    if (expectation.shouldBeOn && !item.available) {
      issues.push({
        sku: expectation.sku,
        title: expectation.title,
        kind: 'off',
        message: `${expectation.title}: apagado o suspendido por la app`,
      });
      continue;
    }

    if (expectation.promoPrice !== undefined && item.price > expectation.promoPrice) {
      issues.push({
        sku: expectation.sku,
        title: expectation.title,
        kind: 'full_price',
        message: `${expectation.title}: a precio full (S/ ${item.price} vs promo S/ ${expectation.promoPrice})`,
      });
    }
  }

  return issues;
}
