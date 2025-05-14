import { GoogleSheetsService } from './googleSheets';
import {
  addExercise,
  createWorkout,
  Group,
  GroupList,
  Workout,
} from './WorkoutModels';

export class WorkoutRepository {
  private googleSheetsService: GoogleSheetsService;
  constructor(googleSheetsService: GoogleSheetsService) {
    this.googleSheetsService = googleSheetsService;
  }
  async getWorkoutData(sheetName: string) {
    const data = await this.googleSheetsService.getSheetData(sheetName);
    return createWorkoutGroup(sheetName, data);
  }
}

export function createWorkoutGroup(name: string, rows: any[][]) {
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
