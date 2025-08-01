import React, { useState } from 'react';
import type { Schedule, Workout } from '../types/Types.ts';
import CreateWorkoutForm from './CreateWorkoutForm.tsx';
import { apiService } from '../services/api.ts';

const ScheduleForm: React.FC = () => {
  const [schedule, setSchedule] = useState<Schedule>({
    name: '',
    workouts: [],
  });
  const [activeWorkoutDay, setActiveWorkout] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleScheduleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSchedule((prev) => ({
      ...prev,
      name: e.target.value,
    }));
    // Clear messages when user starts typing
    setError(null);
    setSuccessMessage(null);
  };

  const handleAddWorkout = () => {
    setActiveWorkout('');
  };

  const handleSaveWorkout = (workout: Workout) => {
    setSchedule((prev) => {
      const isEditing = prev.workouts.some((w) => w.name === activeWorkoutDay);

      if (isEditing) {
        // Update existing workout
        return {
          ...prev,
          workouts: prev.workouts.map((w) =>
            w.name === activeWorkoutDay ? workout : w
          ),
        };
      } else {
        // Add new workout
        return {
          ...prev,
          workouts: [...prev.workouts, workout],
        };
      }
    });
    setActiveWorkout(null);
  };

  const handleCancelWorkout = () => {
    setActiveWorkout(null);
  };

  const handleEditWorkout = (name: string) => {
    setActiveWorkout(name);
  };

  const handleDeleteWorkout = (name: string) => {
    setSchedule((prev) => ({
      ...prev,
      workouts: prev.workouts.filter((w) => w.name !== name),
    }));
  };

  const handleSaveSchedule = async () => {
    if (!schedule.name.trim()) {
      setError('Please enter a schedule name.');
      return;
    }

    if (schedule.workouts.length === 0) {
      setError('Please add at least one workout to the schedule.');
      return;
    }

    setIsLoading(true);
    setError(null);
    setSuccessMessage(null);

    try {
      const createdSchedule = await apiService.createSchedule(schedule);
      setSuccessMessage(
        `Schedule "${createdSchedule.name}" created successfully!`
      );

      // Reset form after successful creation
      setSchedule({
        name: '',
        workouts: [],
      });
    } catch (error) {
      console.error('Error creating schedule:', error);
      setError(
        error instanceof Error
          ? error.message
          : 'Failed to create schedule. Please try again.'
      );
    } finally {
      setIsLoading(false);
    }
  };

  const getCurrentWorkout = (): Workout | undefined => {
    if (activeWorkoutDay === null) return undefined;
    return schedule.workouts.find((w) => w.name === activeWorkoutDay);
  };

  if (activeWorkoutDay !== null) {
    return (
      <CreateWorkoutForm
        initialWorkout={getCurrentWorkout()}
        initialWorkoutName={activeWorkoutDay}
        onSave={handleSaveWorkout}
        onCancel={handleCancelWorkout}
        isEditing={getCurrentWorkout() !== undefined}
      />
    );
  }

  return (
    <div className="container py-4" style={{ maxWidth: '900px' }}>
      <div className="card shadow-sm">
        <div className="card-header bg-primary text-white">
          <h4 className="mb-0">Create Workout Schedule</h4>
        </div>

        <div className="card-body border-bottom">
          {error && (
            <div className="alert alert-danger" role="alert">
              {error}
            </div>
          )}
          {successMessage && (
            <div className="alert alert-success" role="alert">
              {successMessage}
            </div>
          )}
          <div className="mb-3">
            <label htmlFor="scheduleName" className="form-label fw-bold">
              Schedule Name
            </label>
            <input
              type="text"
              className="form-control"
              id="scheduleName"
              value={schedule.name}
              onChange={handleScheduleNameChange}
              placeholder="Enter schedule name (e.g., Upper/Lower Split, Push/Pull/Legs)"
              disabled={isLoading}
              required
            />
          </div>
        </div>

        <div className="card-body">
          <div className="d-flex justify-content-between align-items-center mb-4">
            <h5 className="mb-0">Workouts ({schedule.workouts.length})</h5>
            <button
              className="btn btn-outline-primary"
              onClick={handleAddWorkout}
              disabled={isLoading}
            >
              + Add Workout
            </button>
          </div>

          {schedule.workouts.length === 0 ? (
            <div className="text-muted text-center py-5 border rounded bg-light">
              <p className="mb-2">No workouts added yet.</p>
              <small>Click "Add Workout" to create your first workout.</small>
            </div>
          ) : (
            <div className="row g-3">
              {schedule.workouts.map((workout) => (
                <div key={workout.name} className="col-md-6 col-lg-4">
                  <div className="card h-100 border">
                    <div className="card-header bg-light d-flex justify-content-between align-items-center">
                      <h6 className="mb-0 fw-bold">Day {workout.name}</h6>
                      <div className="btn-group btn-group-sm">
                        <button
                          className="btn btn-outline-secondary"
                          onClick={() => handleEditWorkout(workout.name)}
                          title="Edit workout"
                        >
                          ✏️
                        </button>
                        <button
                          className="btn btn-outline-danger"
                          onClick={() => handleDeleteWorkout(workout.name)}
                          title="Delete workout"
                        >
                          🗑️
                        </button>
                      </div>
                    </div>
                    <div className="card-body">
                      {Object.entries(workout.exercises).map(
                        ([group, exercises]) => (
                          <div key={group} className="mb-2">
                            <small className="fw-bold text-capitalize text-muted">
                              {group}:
                            </small>
                            <ul className="list-unstyled mb-0 ms-2">
                              {exercises?.map((exercise) => (
                                <li key={exercise.id} className="small">
                                  {exercise.name}
                                  {exercise.sets && ` - ${exercise.sets} sets`}
                                  {exercise.reps && ` × ${exercise.reps}`}
                                </li>
                              ))}
                            </ul>
                          </div>
                        )
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="d-flex justify-content-end gap-2 mt-4">
            <button
              className="btn btn-success"
              onClick={handleSaveSchedule}
              disabled={
                isLoading ||
                !schedule.name.trim() ||
                schedule.workouts.length === 0
              }
            >
              {isLoading ? (
                <>
                  <span
                    className="spinner-border spinner-border-sm me-2"
                    role="status"
                    aria-hidden="true"
                  ></span>
                  Creating...
                </>
              ) : (
                'Save Schedule'
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ScheduleForm;
