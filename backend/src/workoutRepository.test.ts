import { createScheduleFromRows } from './workoutRepository.js';
import { readFileSync } from 'fs';
import { parse } from 'csv-parse/sync';

describe('WorkoutRepository', () => {
  describe('createScheduleFromRows', () => {
    test('creates schedule from sample CSV data', () => {
      const sampleData = [
        ['Day', 'Group', 'Name', 'Sets', 'Reps', 'Weight', 'Notes'],
        [
          '1',
          'primary',
          'Seated Strict Press DB',
          '4',
          '',
          '15',
          '8 with 6" eccentric',
        ],
        [
          '1',
          'primary',
          'Bent over straight arm extension with DB',
          '4',
          '12',
          '10-15',
          '',
        ],
        [
          '1',
          'secondary',
          'Dumbbell reverse lunge',
          '4',
          '8',
          '35lbs - 50lbs',
          'heavy',
        ],
        [
          '1',
          'cardio',
          '10 Medball squat cleans (20-30lbs)',
          '3',
          '',
          '',
          'metcon',
        ],
        ['2', 'primary', 'Cable lat pull down', '3', '12', '50-70lbs', ''],
        ['3', 'core', 'Alternating V ups', '4', '10', '', ''],
      ];

      const schedule = createScheduleFromRows('Test Schedule', sampleData);

      expect(schedule.name).toBe('Test Schedule');
      expect(schedule.id).toBeDefined();
      expect(schedule.workouts).toHaveLength(3);

      // Check Day 1 workout
      const day1Workout = schedule.workouts.find((w) => w.name === '1');
      expect(day1Workout).toBeDefined();
      expect(day1Workout!.exercises.primary).toHaveLength(2);
      expect(day1Workout!.exercises.secondary).toHaveLength(1);
      expect(day1Workout!.exercises.cardio).toHaveLength(1);

      // Check specific exercise
      const seatedPress = day1Workout!.exercises.primary![0];
      expect(seatedPress.name).toBe('Seated Strict Press DB');
      expect(seatedPress.sets).toBe(4);
      expect(seatedPress.reps).toBeUndefined();
      expect(seatedPress.weight).toBe('15');

      // Check Day 2 workout
      const day2Workout = schedule.workouts.find((w) => w.name === '2');
      expect(day2Workout).toBeDefined();
      expect(day2Workout!.exercises.primary).toHaveLength(1);

      // Check Day 3 workout
      const day3Workout = schedule.workouts.find((w) => w.name === '3');
      expect(day3Workout).toBeDefined();
      expect(day3Workout!.exercises.core).toHaveLength(1);
    });

    test('handles empty rows array', () => {
      const emptyData = [
        ['Day', 'Group', 'Name', 'Sets', 'Reps', 'Weight', 'Notes'],
      ];

      const schedule = createScheduleFromRows('Empty Schedule', emptyData);

      expect(schedule.name).toBe('Empty Schedule');
      expect(schedule.workouts).toHaveLength(0);
    });

    test('handles missing reps and weight values', () => {
      const testData = [
        ['Day', 'Group', 'Name', 'Sets', 'Reps', 'Weight', 'Notes'],
        ['1', 'primary', 'Test Exercise', '3', '', '', 'test notes'],
      ];

      const schedule = createScheduleFromRows('Test', testData);
      const exercise = schedule.workouts[0].exercises.primary![0];

      expect(exercise.sets).toBe(3);
      expect(exercise.reps).toBeUndefined();
      expect(exercise.weight).toBe('');
      expect(exercise.notes).toBe('test notes');
    });

    test('creates schedule from actual sample.csv file', () => {
      const csvContent = readFileSync('./src/sample.csv', 'utf-8');
      const rows = parse(csvContent, { skip_empty_lines: true });

      const schedule = createScheduleFromRows('Sample Schedule', rows);

      expect(schedule.name).toBe('Sample Schedule');
      expect(schedule.id).toBeDefined();
      expect(schedule.workouts).toHaveLength(3);

      // Verify day structure
      const day1 = schedule.workouts.find((w) => w.name === '1');
      const day2 = schedule.workouts.find((w) => w.name === '2');
      const day3 = schedule.workouts.find((w) => w.name === '3');

      expect(day1).toBeDefined();
      expect(day2).toBeDefined();
      expect(day3).toBeDefined();

      // Check Day 1 has multiple exercise groups
      expect(day1!.exercises.primary).toBeDefined();
      expect(day1!.exercises.secondary).toBeDefined();
      expect(day1!.exercises.cardio).toBeDefined();
      expect(day1!.exercises.primary!.length).toBeGreaterThan(0);

      // Check Day 3 has core exercises
      expect(day3!.exercises.core).toBeDefined();
      expect(day3!.exercises.core!.length).toBeGreaterThan(0);

      // Verify specific exercise from sample data
      const seatedPress = day1!.exercises.primary!.find(
        (e) => e.name === 'Seated Strict Press DB'
      );
      expect(seatedPress).toBeDefined();
      expect(seatedPress!.sets).toBe(4);
      expect(seatedPress!.weight).toBe('15');
    });
  });
});
