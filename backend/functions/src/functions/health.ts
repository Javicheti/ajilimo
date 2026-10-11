import { onRequest } from 'firebase-functions/v2/https';

/** Health check del backend. */
export const health = onRequest((_req, res) => {
  res.status(200).json({
    ok: true,
    service: 'ajilimo',
    projectId: process.env.GCLOUD_PROJECT ?? 'ajilimo-830ca',
    timestamp: new Date().toISOString(),
  });
});
