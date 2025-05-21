import fs from 'fs';
import { parse } from 'csv-parse/sync';
import { createWorkoutGroup } from './workoutRepository';

const sampleWorkoutData = fs.readFileSync('./src/sampleWorkoutData.csv');
const testdata = parse(sampleWorkoutData, {
  columns: false,
  skip_empty_lines: true,
});

test('getWorkoutGroup returns correct result', () => {
  const result = createWorkoutGroup('Week 1', testdata);
  console.dir(result, { depth: null });
});
