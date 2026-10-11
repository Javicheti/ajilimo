import { requestJson } from '../../shared/http';
import type { TokenResult } from '../../security/token-vault';

interface LoginResponse {
  access_token: string;
  token_type?: string;
  expires_in?: number;
}

/**
 * Obtiene un token de integrador (M2M) vía client_credentials.
 * POST /restaurants/auth/v1/token/login/integrations
 */
export async function fetchIntegratorToken(
  baseUrl: string,
  clientId: string,
  clientSecret: string,
): Promise<TokenResult> {
  const response = await requestJson<LoginResponse>({
    url: `${baseUrl}/restaurants/auth/v1/token/login/integrations`,
    method: 'POST',
    body: { client_id: clientId, client_secret: clientSecret },
    retries: 1,
  });

  return {
    token: response.access_token,
    expiresInSeconds: response.expires_in ?? 7 * 24 * 60 * 60,
  };
}
