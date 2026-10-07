const axios = require('axios');

async function fixRoleViaApi() {
  // We will hit the backend API to force update the role, but there is no update role endpoint!
  // We can only do syncUser.
  try {
    const res = await axios.post('http://localhost:5000/api/users/sync', {
      firebaseUID: '1PMulLzXUqbv4KRrLu2BJ0qLSXx2', // The staff UID
      email: 'sbgopinath213@gmail.com',
      role: 'Student' // Wait, syncUser PRESERVES existing role!
    });
    console.log(res.data);
  } catch (e) {
    console.error(e.response?.data || e.message);
  }
}

fixRoleViaApi();
