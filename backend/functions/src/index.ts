import { initializeApp } from 'firebase-admin/app';
import { setGlobalOptions } from 'firebase-functions/v2';

initializeApp();

setGlobalOptions({ region: 'us-central1', maxInstances: 10 });

export { health } from './functions/health';
export { rappiWebhook } from './functions/rappiWebhook';
export { api } from './functions/api';
export { bootstrapOwner, setUserRole } from './functions/admin';
