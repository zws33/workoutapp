import { GoogleSheetsService } from './googleSheetsService';
import {
  addExercise,
  createWorkout,
  Group,
  GroupList,
  Workout,
  WorkoutGroup,
} from './models';
import cron from 'node-cron';

const WORKOUTS_COLLECTION = 'workouts';

type SheetsResponse = string[][];

export class WorkoutRepository {
  private googleSheetsService: GoogleSheetsService;
  private db: FirebaseFirestore.Firestore;
  constructor(
    googleSheetsService: GoogleSheetsService,
    db: FirebaseFirestore.Firestore
  ) {
    this.googleSheetsService = googleSheetsService;
    this.db = db;
  }

  startCronJob(): void {
    cron.schedule('0 0 * * *', async () => {
      console.log('Running cron job to fetch workout data...');
      try {
        const sheets = await this.googleSheetsService.getSheetNames();
        await Promise.all(
          sheets.map(async (sheetName) => {
            const data = await this.googleSheetsService.getSheetData(sheetName);
            const workoutGroup = createWorkoutGroup(sheetName, data);
            await this.db
              .collection(WORKOUTS_COLLECTION)
              .doc(workoutGroup.name)
              .set(workoutGroup);
          })
        );
        console.log('Workout data successfully updated in Firestore.');
      } catch (error) {
        console.error('Error during cron job:', error);
      }
    });
  }

  async getWorkoutData(sheetName: string): Promise<WorkoutGroup> {
    try {
      const snapshot = await this.db
        .collection(WORKOUTS_COLLECTION)
        .doc(sheetName)
        .get();

      if (!snapshot.exists) {
        throw new Error(`Workout document for ${sheetName} does not exist.`);
      }
      return snapshot.data() as WorkoutGroup;
    } catch (error) {
      console.error(`Error getting data for ${sheetName}:`, error);
      throw new Error(`Failed to fetch data for ${sheetName}`);
    }
  }
}

export function createWorkoutGroup(name: string, rows: SheetsResponse) {
  const workouts: Record<string, Workout> = {};

  rows.slice(1).forEach((row) => {
    const [day, group, name, sets, reps, weight, notes] = row;

    if (
      typeof day !== 'string' ||
      typeof group !== 'string' ||
      typeof name !== 'string' ||
      !GroupList.includes(group.toLowerCase() as Group)
    ) {
      throw new Error(
        `Invalid data format. Expected day, group, name, sets, reps, weight, notes. Received: ${row}`
      );
    }

    const workout = workouts[day] ?? createWorkout(day);

    addExercise(workout, group as Group, {
      name,
      sets: parseInt(sets) || 0,
      reps: parseInt(reps) || 0,
      weight: parseFloat(weight) || 0,
      notes: notes ?? '',
    });
    workouts[day] = workout;
  });

  return {
    name,
    workouts,
  };
}
