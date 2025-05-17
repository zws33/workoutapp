import admin from 'firebase-admin';

export const firestore = async () => {
  if (!admin.apps.length) {
    const __dirname = new URL('../', import.meta.url).pathname;
    const credentialsPath = `${__dirname}credentials.json`;
    admin.initializeApp({
      credential: admin.credential.cert(credentialsPath),
    });
  } else {
    console.log('Firebase app already initialized');
  }
  return admin.firestore();
};
