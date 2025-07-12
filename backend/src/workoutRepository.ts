import {GoogleSheetsService} from './googleSheetsService.js';
import {
  addExercise,
  createExercise,
  createSchedule,
  createWorkout,
  createWorkoutData,
  Exercise,
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

  async createSchedule(scheduleData: { name: string; workouts: any[] }): Promise<Schedule> {
    // Validate input
    if (!scheduleData.name?.trim()) {
      throw new Error('Schedule name is required');
    }
    
    if (!scheduleData.workouts || scheduleData.workouts.length === 0) {
      throw new Error('At least one workout is required');
    }

    // Check if schedule already exists
    try {
      const existing = await this.db.getScheduleByName(scheduleData.name);
      if (existing) {
        throw new Error(`Schedule with name '${scheduleData.name}' already exists`);
      }
    } catch (error) {
      // If error is not about not finding the schedule, re-throw
      if (error instanceof Error && !error.message.includes('does not exist')) {
        throw error;
      }
    }

    // Transform workouts and create schedule
    const workouts: Workout[] = scheduleData.workouts.map((workoutData) => {
      // Validate workout structure
      if (!workoutData.day || !workoutData.exercises) {
        throw new Error('Each workout must have a day and exercises');
      }

      // Transform exercises to use backend ID generation
      const transformedExercises: Partial<Record<Group, Exercise[]>> = {};
      
      for (const [group, exercises] of Object.entries(workoutData.exercises)) {
        if (exercises && Array.isArray(exercises)) {
          transformedExercises[group as Group] = exercises.map((exercise: any) => 
            createExercise(
              exercise.name,
              exercise.sets,
              exercise.reps || undefined,
              exercise.weight || undefined,
              exercise.notes || undefined
            )
          );
        }
      }

      return createWorkout(workoutData.day, transformedExercises);
    });

    const schedule = createSchedule(scheduleData.name, workouts);
    await this.db.saveSchedule(schedule);
    
    return schedule;
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
