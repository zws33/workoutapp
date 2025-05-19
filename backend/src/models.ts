export const GroupList = ['primary', 'secondary', 'cardio', 'core'] as const;
export type Group = (typeof GroupList)[number];

export interface Exercise {
  name: string;
  sets: number;
  reps: number;
  weight: string;
  notes: string;
}

export interface Workout {
  day: string;
  exercises: Partial<Record<Group, Exercise[]>>;
}

export interface WorkoutGroup {
  name: string;
  workouts: Record<string, Workout>;
}

export function createWorkout(day: string): Workout {
  return {
    day,
    exercises: {},
  };
}

export function addExercise(
  workout: Workout,
  group: Group,
  exercise: Exercise
): void {
  if (!workout.exercises[group]) {
    workout.exercises[group] = [];
  }
  workout.exercises[group]!.push(exercise);
}
