/**
 * Developer / Admin Account Provisioning Script
 * Usage: node scripts/create_admin.js <email> <firebaseUID> [name]
 * Example: node scripts/create_admin.js admin@institution.edu 1PMulLzXUqbv4KRrLu2BJ0qLSXx2 "System Admin"
 */
require('dotenv').config();
const mongoose = require('mongoose');

const args = process.argv.slice(2);
const email = args[0];
const firebaseUID = args[1];
const name = args[2] || 'System Administrator';

if (!email || !firebaseUID) {
  console.error('\nError: Missing required parameters.');
  console.error('Usage: node scripts/create_admin.js <email> <firebaseUID> [name]\n');
  process.exit(1);
}

const uri = process.env.MONGODB_URI;
if (!uri) {
  console.error('Error: MONGODB_URI is not set in .env file.');
  process.exit(1);
}

mongoose
  .connect(uri)
  .then(async () => {
    console.log('Connected to MongoDB.');
    const db = mongoose.connection.db;

    const filter = { $or: [{ firebaseUID }, { email }] };
    const update = {
      $set: {
        firebaseUID,
        email,
        role: 'Admin',
        name,
        department: 'Administration',
        isProfileCompleted: true,
        emailVerified: true,
        updatedAt: new Date(),
      },
      $setOnInsert: {
        createdAt: new Date(),
      },
    };

    const result = await db.collection('users').updateOne(filter, update, { upsert: true });

    console.log(`Success! Admin user profile provisioned for ${email}.`);
    console.log(`Matched: ${result.matchedCount}, Modified: ${result.modifiedCount}, Upserted: ${result.upsertedCount}`);

    const user = await db.collection('users').findOne({ firebaseUID });
    console.log('\nProvisioned Admin Profile:');
    console.log(JSON.stringify(user, null, 2));

    process.exit(0);
  })
  .catch((err) => {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1);
  });
