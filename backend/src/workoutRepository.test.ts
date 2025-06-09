import fs from 'fs';
import { parse } from 'csv-parse/sync';
import { createSchedule } from './workoutRepository.js';

const sampleWorkoutData = fs.readFileSync('./src/sampleWorkoutData.csv');
const testdata = parse(sampleWorkoutData, {
  columns: false,
  skip_empty_lines: true,
});

test('getWorkoutGroup returns correct result', () => {
  const result = createSchedule('Week 1', testdata);
});
