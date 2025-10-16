const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// You need to download service account key from Firebase Console
// Go to Project Settings → Service Accounts → Generate New Private Key
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://trustcard-aee4a-default-rtdb.firebaseio.com'
});

async function setAdmin(email) {
  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    console.log(`✅ ${email} is now admin (UID: ${user.uid})`);
  } catch (error) {
    console.error(`❌ Error setting admin for ${email}:`, error.message);
  }
}

async function listAdmins() {
  try {
    const listUsersResult = await admin.auth().listUsers();
    const admins = [];
    
    for (const user of listUsersResult.users) {
      const customClaims = user.customClaims;
      if (customClaims && customClaims.admin === true) {
        admins.push({
          email: user.email,
          uid: user.uid,
          displayName: user.displayName
        });
      }
    }
    
    console.log('👑 Current Admins:');
    admins.forEach(admin => {
      console.log(`  - ${admin.email} (${admin.displayName || 'No name'})`);
    });
    
    if (admins.length === 0) {
      console.log('  No admins found');
    }
  } catch (error) {
    console.error('❌ Error listing admins:', error.message);
  }
}

// Command line usage
const command = process.argv[2];
const email = process.argv[3];

if (command === 'set' && email) {
  setAdmin(email).then(() => process.exit(0));
} else if (command === 'list') {
  listAdmins().then(() => process.exit(0));
} else {
  console.log(`
🔧 Firebase Admin Setup Script

Usage:
  node set_admin.js set <email>     - Set user as admin
  node set_admin.js list             - List all admins

Examples:
  node set_admin.js set manish@email.com
  node set_admin.js set admin@trustcard.com
  node set_admin.js list

Note: You need service-account-key.json in this directory
Get it from Firebase Console → Project Settings → Service Accounts
  `);
  process.exit(1);
}
