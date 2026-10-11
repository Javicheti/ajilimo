import type { ChannelProvider } from './types';
import type { ConnectorContext, DeliveryConnector } from './delivery-connector';
import { RappiConnector } from '../rappi/rappi-connector';
import { DidiConnector } from '../didi/didi-connector';
import { PedidosYaConnector } from '../pedidosya/pedidosya-connector';

/** Constructor de conectores por proveedor. */
export type ConnectorBuilder = (context: ConnectorContext) => DeliveryConnector;

const builders: Partial<Record<ChannelProvider, ConnectorBuilder>> = {
  rappi: (context) => new RappiConnector(context),
  didi: (context) => new DidiConnector(context),
  pedidosya: (context) => new PedidosYaConnector(context),
};

/** Registra (o reemplaza) el constructor de un proveedor. */
export function registerConnector(provider: ChannelProvider, builder: ConnectorBuilder): void {
  builders[provider] = builder;
}

/** Crea el conector adecuado para el proveedor dado. */
export function createConnector(
  provider: ChannelProvider,
  context: ConnectorContext,
): DeliveryConnector {
  const builder = builders[provider];
  if (!builder) {
    throw new Error(`Conector no soportado todavía: ${provider}`);
  }
  return builder(context);
}
