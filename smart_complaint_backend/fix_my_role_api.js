const axios = require('axios');

async function forceUpdateRole() {
  const firebaseUID = '1PMulLzXUqbv4KRrLu2BJ0qLSXx2'; // The UID you provided earlier
  
  try {
    const res = await axios.put(`http://localhost:5000/api/users/profile/${firebaseUID}`, {
      role: 'Student',
      registerNumber: '913123000', // Dummy register number to satisfy validation
      year: 'I Year'
    });
    console.log('Successfully updated account to Student!');
    console.log(res.data);
  } catch (error) {
    console.error('Failed to update account:', error.response ? error.response.data : error.message);
  }
}

forceUpdateRole();
