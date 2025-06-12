export interface Exercise {
  id?: string;
  name: string;
  sets: number | undefined | null;
  reps: number | undefined | null;
  weight: string;
  notes: string;
}
