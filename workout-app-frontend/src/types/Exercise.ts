export interface Exercise {
  id?: string;
  group: Group
  name: string;
  sets: number;
  reps: number | null;
  weight: string | null;
  notes: string | null;
}

export type Group = 'primary' | 'secondary' | 'cardio' | 'core';

export type ExerciseGroups = Partial<Record<Group, Exercise[]>>;

export interface Workout {
  id?: string;
  day: number;
  exercises: ExerciseGroups;
}

export interface Schedule {
  id?: string;
  name: string;
  workouts: Workout[];
}
