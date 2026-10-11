import { AppError } from '../shared/errors';

export type TenantEnvironment = 'dev' | 'prod';

export interface Tenant {
  id: string;
  name: string;
  slug: string;
  environment: TenantEnvironment;
}

/** Normaliza un nombre a slug estable para IDs y rutas de secretos. */
export function slugify(name: string): string {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/** Construye un tenant validando el nombre y derivando su namespace de secretos. */
export function buildTenant(
  name: string,
  environment: TenantEnvironment,
  id?: string,
): { tenant: Tenant; secretNamespace: string } {
  const slug = slugify(name);
  if (!slug) {
    throw new AppError('invalid_config', 'El nombre del tenant no es válido');
  }
  return {
    tenant: { id: id ?? slug, name: name.trim(), slug, environment },
    secretNamespace: `tenants/${slug}`,
  };
}
