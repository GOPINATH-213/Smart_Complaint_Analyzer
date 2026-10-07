const admin = require('firebase-admin');
const config = require('./index');
const logger = require('./logger');

if (admin.apps && !admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: config.firebase.projectId,
        clientEmail: config.firebase.clientEmail,
        privateKey: config.firebase.privateKey,
      }),
      storageBucket: config.firebase.storageBucket,
    });
    logger.info('Firebase Admin SDK initialized successfully');
  } catch (error) {
    logger.error('Firebase Admin SDK initialization error', { error: error.message });
  }
}

module.exports = admin;
