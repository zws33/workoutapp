import { createHash } from "./utils.js";
export const GroupList = ["primary", "secondary", "cardio", "core"] as const;
export type Group = (typeof GroupList)[number];

export interface Exercise {
  id: string;
  name: string;
  sets: number;
  reps?: number;
  weight?: string;
  notes?: string;
}

export interface Workout {
  id: string;
  name: string;
  exercises: Partial<Record<Group, Exercise[]>>;
}

export interface Schedule {
  id: string;
  name: string;
  workouts: Workout[];
}

export function createWorkout(
  name: string,
  exercises: Partial<Record<Group, Exercise[]>>,
): Workout {
  return {
    id: createHash({ name: name, exercises }),
    name: name,
    exercises,
  };
}

export type WorkoutData = Omit<Workout, "id">;

export function createWorkoutData(name: string): WorkoutData {
  return {
    name: name,
    exercises: {},
  };
}

export function createExercise(
  name: string,
  sets: number,
  reps?: number,
  weight?: string,
  notes?: string,
): Exercise {
  return {
    id: createHash({
      name,
      sets,
      reps,
      weight,
      notes,
    }),
    name,
    sets,
    reps,
    weight,
    notes,
  };
}

export function createSchedule(name: string, workouts: Workout[]): Schedule {
  return {
    id: createHash({
      name,
      workouts,
    }),
    name,
    workouts,
  };
}

export function addExercise(
  workout: WorkoutData,
  group: Group,
  exercise: Exercise,
): void {
  if (!workout.exercises[group]) {
    workout.exercises[group] = [];
  }
  workout.exercises[group]!.push(exercise);
}
