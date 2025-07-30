import {
  createWorkout,
  createExercise,
  createSchedule,
  createWorkoutData,
} from "./models.js";

describe("Models", () => {
  test("createWorkout generates deterministic ID from content", () => {
    const exercises = { primary: [] };
    const workout1 = createWorkout("Monday", exercises);
    const workout2 = createWorkout("Monday", exercises);

    expect(workout1.id).toBeDefined();
    expect(workout2.id).toBeDefined();
    expect(workout1.id).toBe(workout2.id); // Same content = same ID
    expect(workout1.day).toBe("Monday");
  });

  test("createWorkout generates different IDs for different content", () => {
    const workout1 = createWorkout("Monday", {});
    const workout2 = createWorkout("Tuesday", {});

    expect(workout1.id).not.toBe(workout2.id);
  });

  test("createExercise generates deterministic ID from content", () => {
    const exercise1 = createExercise(
      "Push-ups",
      3,
      15,
      "Bodyweight",
      "Keep form strict",
    );
    const exercise2 = createExercise(
      "Push-ups",
      3,
      15,
      "Bodyweight",
      "Keep form strict",
    );

    expect(exercise1.id).toBeDefined();
    expect(exercise2.id).toBeDefined();
    expect(exercise1.id).toBe(exercise2.id); // Same content = same ID
    expect(exercise1.name).toBe("Push-ups");
    expect(exercise1.sets).toBe(3);
    expect(exercise1.reps).toBe(15);
  });

  test("createExercise generates different IDs for different content", () => {
    const exercise1 = createExercise("Push-ups", 3, 15);
    const exercise2 = createExercise("Pull-ups", 3, 15);

    expect(exercise1.id).not.toBe(exercise2.id);
  });

  test("createSchedule generates deterministic ID from content", () => {
    const workout = createWorkout("Monday", {});
    const schedule1 = createSchedule("Week 1", [workout]);
    const schedule2 = createSchedule("Week 1", [workout]);

    expect(schedule1.id).toBeDefined();
    expect(schedule2.id).toBeDefined();
    expect(schedule1.id).toBe(schedule2.id); // Same content = same ID
    expect(schedule1.name).toBe("Week 1");
    expect(schedule1.workouts).toHaveLength(1);
  });

  test("createWorkoutData creates workout without ID", () => {
    const workoutData = createWorkoutData("Friday");

    expect(workoutData.day).toBe("Friday");
    expect(workoutData.exercises).toEqual({});
    expect("id" in workoutData).toBe(false);
  });
});
