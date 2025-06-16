import { getFirestore } from 'firebase-admin/firestore';

import {Schedule} from './models.js';

const WORKOUTS_COLLECTION = 'workouts';
export const getWorkoutDb = (): WorkoutDb => {
  let firestoreDb = getFirestore();
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
        return undefined;
      }
      return snapshot.data() as Schedule;
    },
    getSchedules: async () => {
      const snapshots = await firestoreDb
        .collection(WORKOUTS_COLLECTION)
        .get();
      return snapshots.docs.map((doc) => doc.data() as Schedule);
    }
  }
};

export interface WorkoutDb {
  saveSchedule(schedule: Schedule): Promise<void>;
  getScheduleByName(name: string): Promise<Schedule | undefined>;
  getSchedules(): Promise<Schedule[]>;
}
