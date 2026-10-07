const path = require('path');
const fs = require('fs');

const nodeEnv = process.env.NODE_ENV || 'development';
const envPath = path.resolve(process.cwd(), '.env');

if (fs.existsSync(envPath)) {
  require('dotenv').config({ path: envPath });
} else {
  const envFile = `.env.${nodeEnv}`;
  const backupPath = path.resolve(process.cwd(), envFile);
  if (fs.existsSync(backupPath)) {
    require('dotenv').config({ path: backupPath });
  } else {
    require('dotenv').config();
  }
}

// Configuration schema definition
const config = {
  server: {
    port: parseInt(process.env.PORT, 10) || 5000,
    env: nodeEnv,
    apiVersion: process.env.API_VERSION || 'v1',
    baseUrl: process.env.BASE_URL || 'http://localhost:5000',
  },
  database: {
    uri: process.env.MONGODB_URI,
    name: process.env.DATABASE_NAME || 'smart_complaint_analyzer',
  },
  security: {
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
    bcryptSaltRounds: parseInt(process.env.BCRYPT_SALT_ROUNDS, 10) || 10,
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 900000,
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10) || 100,
  },
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : undefined,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY,
    model: process.env.GEMINI_MODEL || 'gemini-1.5-flash',
  },
  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME,
    apiKey: process.env.CLOUDINARY_API_KEY,
    apiSecret: process.env.CLOUDINARY_API_SECRET,
  },
  email: {
    brevoApiKey: process.env.BREVO_API_KEY,
    senderEmail: process.env.BREVO_SENDER_EMAIL,
    senderName: process.env.BREVO_SENDER_NAME || 'Smart Complaint Analyzer',
  },
  logging: {
    level: process.env.LOG_LEVEL || 'info',
  },
};

// Validate required configurations (Fail-Fast startup check)
const requiredVars = {
  'MONGODB_URI': config.database.uri,
  'JWT_SECRET': config.security.jwtSecret,
  'FIREBASE_PROJECT_ID': config.firebase.projectId,
  'FIREBASE_CLIENT_EMAIL': config.firebase.clientEmail,
  'FIREBASE_PRIVATE_KEY': config.firebase.privateKey,
  'GEMINI_API_KEY': config.gemini.apiKey,
  'CLOUDINARY_CLOUD_NAME': config.cloudinary.cloudName,
  'CLOUDINARY_API_KEY': config.cloudinary.apiKey,
  'CLOUDINARY_API_SECRET': config.cloudinary.apiSecret,
  'BREVO_API_KEY': config.email.brevoApiKey,
  'BREVO_SENDER_EMAIL': config.email.senderEmail,
};

const missing = [];
for (const [key, value] of Object.entries(requiredVars)) {
  if (!value) {
    missing.push(key);
  }
}

if (missing.length > 0) {
  console.error('\x1b[31m%s\x1b[0m', `FATAL STARTUP ERROR: Missing required environment variables: ${missing.join(', ')}`);
  process.exit(1);
}

module.exports = config;
