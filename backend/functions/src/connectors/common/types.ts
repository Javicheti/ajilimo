/** Proveedor de canal de delivery. */
export type ChannelProvider = 'rappi' | 'didi' | 'pedidosya';

/** Entorno de integración. */
export type Environment = 'mock' | 'dev' | 'prod';

/** Capacidades que puede ofrecer un canal. */
export type Capability =
  | 'stores'
  | 'menu'
  | 'availability'
  | 'orders'
  | 'promos'
  | 'claims'
  | 'financial';

/** Resumen de tienda normalizado entre canales. */
export interface StoreSummary {
  storeId: string;
  name: string;
  brand?: string;
  integrated?: boolean;
}

/** Ítem de menú normalizado (incluye estado de suspensión y horarios). */
export interface MenuItem {
  id: string;
  sku: string;
  title: string;
  price: number;
  available: boolean;
  suspendReason?: string | null;
  daysOfWeek?: string[];
}

/** Disponibilidad de tienda normalizada. */
export interface StoreAvailability {
  storeId: string;
  online: boolean;
}

/** Ítem de una orden. */
export interface OrderItem {
  sku: string;
  name: string;
  quantity: number;
  price: number;
}

/** Orden normalizada. */
export interface Order {
  orderId: string;
  storeId: string;
  status: string;
  items: OrderItem[];
}

/** Opciones al tomar una orden. */
export interface TakeOrderOptions {
  cookingTimeMinutes?: number;
}

/** Ventana de horario (días + rango horario). */
export interface ScheduleWindow {
  daysOfWeek: string[];
  startTime: string;
  endTime: string;
}

/** Estado operativo resuelto de una tienda. */
export type StoreOnlineStatus = 'open' | 'closed' | 'paused' | 'suspended';
