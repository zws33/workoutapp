import {GoogleSheetsService} from './googleSheetsService';
import {
  addExercise,
  createWorkout,
  Group,
  Workout,
  Schedule,
} from './models';
import cron from 'node-cron';
import {WorkoutDb} from "./workoutDb";

export class WorkoutRepository {
  private googleSheetsService: GoogleSheetsService;
  private db: WorkoutDb;

  constructor(
    googleSheetsService: GoogleSheetsService,
    db: WorkoutDb
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
            const schedule = createWorkoutGroup(sheetName, data);
            await this.db.saveSchedule(schedule);
          })
        );
        console.log('Workout data successfully updated in Firestore.');
      } catch (error) {
        console.error('Error during cron job:', error);
      }
    });
  }

  async getWorkoutData(sheetName: string): Promise<Schedule> {
    const schedule = await this.db.getScheduleByName(sheetName);
    if(!schedule) {
      throw new Error(`Workout document for ${sheetName} does not exist.`);
    }
    return schedule;
  }
}

export function createWorkoutGroup(name: string, rows: string[][]) {
  const workouts: Record<string, Workout> = {};

  rows.slice(1).forEach((row) => {
    const [day, group, name, sets, reps, weight, notes] = row;

    const workout = workouts[day] ?? createWorkout(day);

    addExercise(workout, group as Group, {
      name,
      sets: parseInt(sets) || 0,
      reps: parseInt(reps) || 0,
      weight: weight || '-',
      notes: notes ?? '',
    });
    workouts[day] = workout;
  });

  return {
    name,
    workouts,
  };
}
