import { createWorkout, createExercise, createSchedule } from './models.js';

describe('Models', () => {
  test('createWorkout generates unique ID', () => {
    const workout1 = createWorkout('Monday');
    const workout2 = createWorkout('Monday');
    
    expect(workout1.id).toBeDefined();
    expect(workout2.id).toBeDefined();
    expect(workout1.id).not.toBe(workout2.id);
    expect(workout1.day).toBe('Monday');
  });

  test('createExercise generates unique ID', () => {
    const exercise1 = createExercise('Push-ups', 3, 15, 'Bodyweight', 'Keep form strict');
    const exercise2 = createExercise('Push-ups', 3, 15, 'Bodyweight', 'Keep form strict');
    
    expect(exercise1.id).toBeDefined();
    expect(exercise2.id).toBeDefined();
    expect(exercise1.id).not.toBe(exercise2.id);
    expect(exercise1.name).toBe('Push-ups');
  });

  test('createSchedule generates unique ID', () => {
    const workout = createWorkout('Monday');
    const schedule1 = createSchedule('Week 1', [workout]);
    const schedule2 = createSchedule('Week 1', [workout]);
    
    expect(schedule1.id).toBeDefined();
    expect(schedule2.id).toBeDefined();
    expect(schedule1.id).not.toBe(schedule2.id);
    expect(schedule1.name).toBe('Week 1');
  });
});