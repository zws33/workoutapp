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
