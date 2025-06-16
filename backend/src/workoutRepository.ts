import {GoogleSheetsService} from './googleSheetsService.js';
import {addExercise, createExercise, createSchedule, createWorkout, Group, Schedule, Workout,} from './models.js';
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
    try {
      const sheets = await this.googleSheetsService.getSheetNames();
      await Promise.all(
        sheets.map(async (sheetName: string) => {
          const data = await this.googleSheetsService.getSheetData(sheetName);
          const schedule = createScheduleFromRows(sheetName, data);
          await this.db.saveSchedule(schedule);
        })
      );
      console.log('Workout data successfully updated in Firestore.');
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
  const workouts: Workout[] = [];

  rows.slice(1).forEach((row) => {
    const [day, group, exerciseName, sets, reps, weight, notes] = row;

    let workout = workouts.find((w) => w.day === day);

    if (!workout) {
      workout = createWorkout(day);
      workouts.push(workout);
    }

    const exercise = createExercise(
      exerciseName,
      parseInt(sets) || 0,
      parseInt(reps) || 0,
      weight || '-',
      notes ?? ''
    );

    addExercise(workout, group as Group, exercise);
  });

  return createSchedule(name, workouts);
}
