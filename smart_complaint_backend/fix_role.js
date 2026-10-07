require('dotenv').config();
const mongoose = require('mongoose');

const uri = process.env.MONGODB_URI;
const targetUID = '1PMulLzXUqbv4KRrLu2BJ0qLSXx2';

mongoose.connect(uri, { dbName: process.env.DATABASE_NAME || 'smart-complaint-analyzer' })
  .then(async () => {
    console.log('Connected to MongoDB.');
    const db = mongoose.connection.db;
    
    const result = await db.collection('users').updateOne(
      { firebaseUID: targetUID },
      { 
        $set: { 
          role: 'Student',
          employeeId: '',
          designation: '',
          isProfileCompleted: false // To prompt them to fill student details (registerNumber, year)
        } 
      }
    );

    console.log(`Matched ${result.matchedCount} document(s) and modified ${result.modifiedCount} document(s).`);
    
    const updatedUser = await db.collection('users').findOne({ firebaseUID: targetUID });
    console.log('Updated user:', JSON.stringify(updatedUser, null, 2));

    process.exit(0);
  })
  .catch(err => {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1);
  });
