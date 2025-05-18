import admin from 'firebase-admin';

export const firestore = () => {
  if (!admin.apps.length) {
    const credentials = process.env.GOOGLE_CREDENTIALS;
    admin.initializeApp({
      credential: admin.credential.cert(`./${credentials}`),
    });
  }
  return admin.firestore();
};
