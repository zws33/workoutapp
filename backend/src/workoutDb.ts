import admin, {firestore} from 'firebase-admin';
import {Schedule} from "./models";

let firestoreDb: firestore.Firestore;
const WORKOUTS_COLLECTION = 'workouts';
export const getWorkoutDb = (): WorkoutDb => {
  if (!admin.apps.length) {
    const credentials = process.env.GOOGLE_CREDENTIALS;
    admin.initializeApp({
      credential: admin.credential.cert(`./${credentials}`),
    });
  }
  firestoreDb = admin.firestore();
  return {
    saveSchedule: async (schedule: Schedule) => {
      await firestoreDb
        .collection(WORKOUTS_COLLECTION)
        .doc(schedule.name)
        .set(schedule);
    },
    getScheduleByName: async (name: string) => {
      const snapshot = await firestoreDb
        .collection(WORKOUTS_COLLECTION)
        .doc(name)
        .get();

      if (!snapshot.exists) {
        throw new Error(`Workout document for ${name} does not exist.`);
      }
      return snapshot.data() as Schedule;
    }
  }
};

export interface WorkoutDb {
  saveSchedule(schedule: Schedule): Promise<void>;
  getScheduleByName(name: string): Promise<Schedule | null>;
}
