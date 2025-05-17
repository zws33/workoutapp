import { parse } from '@std/csv';
import { createWorkoutGroup } from './workoutRepository.ts';

const sampleWorkoutData = Deno.readTextFileSync('./src/sampleWorkoutData.csv');
const testdata = parse(sampleWorkoutData);

Deno.test('getWorkoutGroup returns correct result', () => {
  const result = createWorkoutGroup('Week 1', testdata);
  console.dir(result, { depth: null });
});
