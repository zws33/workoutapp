import admin from 'firebase-admin';

export const firestore = () => {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert('./credentials.json'),
    });
  }
  return admin.firestore();
};
