export interface Exercise {
  id?: string;
  group?: Group
  name: string;
  sets: number | undefined | null;
  reps: number | undefined | null;
  weight: string;
  notes: string;
}
export type Group = 'primary' | 'secondary' | 'cardio' | 'core';
