require('dotenv').config();
const mongoose = require('mongoose');

const uri = process.env.MONGODB_URI;

mongoose.connect(uri)
  .then(async () => {
    console.log('Connected to MongoDB.');
    const db = mongoose.connection.db; // This will resolve to 'test'
    
    const users = await db.collection('users').find({}).toArray();
    console.log('All Users in test DB:', JSON.stringify(users, null, 2));

    process.exit(0);
  })
  .catch(err => {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1);
  });
