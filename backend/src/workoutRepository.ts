import {GoogleSheetsService} from './googleSheetsService.js';
import {
  addExercise,
  createExercise,
  createSchedule,
  createWorkout,
  createWorkoutData,
  Group,
  Schedule,
  Workout, WorkoutData,
} from './models.js';
import cron from 'node-cron';
import {WorkoutDb} from './workoutDb.js';

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
      await this.syncWorkoutData();
    });
  }

  async syncWorkoutData() {
    console.log('Syncing workout data...');
    try {
      const sheets = await this.googleSheetsService.getSheetNames();
      await Promise.all(
        sheets.map(async (sheetName: string) => {
          const data = await this.googleSheetsService.getSheetData(sheetName);
          const schedule = createScheduleFromRows(sheetName, data);
          await this.db.saveSchedule(schedule);
        })
      );
    } catch (error) {
      console.error('Error during cron job:', error);
    }
  }

  async getScheduleByName(sheetName: string): Promise<Schedule> {
    if (!sheetName?.trim()) {
      throw new Error('Sheet name is required');
    }

    const schedule = await this.db.getScheduleByName(sheetName);
    if (!schedule) {
      throw new Error(`Workout document for ${sheetName} does not exist.`);
    }

    return schedule;
  }

  async getSchedules(): Promise<Schedule[]> {
    return await this.db.getSchedules();
  }
}

export function createScheduleFromRows(name: string, rows: string[][]) {
  const workoutData: WorkoutData[] = [];

  let days = new Set(rows.slice(1).map((row) => row[0]));

  rows.slice(1).forEach((row) => {
    const [day, group, exerciseName, sets, reps, weight, notes] = row;

    let workout = workoutData.find((w) => w.day === day);

    if (!workout) {
      workout = createWorkoutData(day);
      workoutData.push(workout);
    }

    const exercise = createExercise(
      exerciseName,
      parseInt(sets) || 0,
      parseInt(reps) || undefined,
      weight,
      notes
    );

    addExercise(workout, group.toLowerCase() as Group, exercise);
  });

  let workouts: Workout[] = workoutData.map((data) => createWorkout(data.day, data.exercises));
  return createSchedule(name, workouts);
}
