import React, { useReducer, useState } from 'react';
import type { Exercise, Group } from '../types/Exercise.ts';
import ExerciseForm from './ExerciseForm.tsx';
import ExerciseList from './ExerciseList.tsx';

type ExerciseGroups = Partial<Record<Group, Exercise[]>>;
type AddExercise = {
  type: 'add';
  exercise: Exercise;
  group: Group;
};
type RemoveExercise = {
  type: 'remove';
  exerciseId: string;
};
type UpdateExercise = {
  type: 'update';
  exercise: Exercise;
};
type CancelEdit = {
  type: 'cancel_edit';
};
type Action = AddExercise | RemoveExercise | UpdateExercise | CancelEdit;

function reducer(state: ExerciseGroups, action: Action): ExerciseGroups {
  switch (action.type) {
    case 'add':
      return {
        ...state,
        [action.group]: [...(state[action.group] || []), action.exercise],
      };
    case 'remove': {
      const newState = { ...state };
      for (const group in newState) {
        if (newState[group as Group]) {
          newState[group as Group] = newState[group as Group]!.filter(
            (ex) => ex.id !== action.exerciseId
          );
          if (newState[group as Group]!.length === 0) {
            delete newState[group as Group];
          }
        }
      }
      return newState;
    }
    case 'update': {
      const newState = { ...state };
      for (const group in newState) {
        if (newState[group as Group]) {
          const exerciseIndex = newState[group as Group]!.findIndex(
            (ex) => ex.id === action.exercise.id
          );
          if (exerciseIndex !== -1) {
            // Remove from current group
            newState[group as Group] = newState[group as Group]!.filter(
              (ex) => ex.id !== action.exercise.id
            );
            if (newState[group as Group]!.length === 0) {
              delete newState[group as Group];
            }
            break;
          }
        }
      }
      // Add to new group
      const targetGroup = action.exercise.group || 'primary';
      return {
        ...newState,
        [targetGroup]: [...(newState[targetGroup] || []), action.exercise],
      };
    }
    case 'cancel_edit':
      return state;
    default:
      return state;
  }
}

const groupOrder: Group[] = ['primary', 'secondary', 'core', 'cardio'];

const CreateWorkoutForm: React.FC<{ workoutName?: string }> = ({
  workoutName = '',
}) => {
  const [name, setSchedule] = useState<string>(workoutName);
  const [exerciseGroups, dispatch] = useReducer(reducer, {} as ExerciseGroups);
  const [editingExerciseId, setEditingExerciseId] = useState<string | null>(
    null
  );

  const handleAddExercise = (newExercise: Exercise): void => {
    if (editingExerciseId) {
      const updatedExercise: Exercise = {
        ...newExercise,
        id: editingExerciseId,
      };
      dispatch({
        type: 'update',
        exercise: updatedExercise,
      });
      setEditingExerciseId(null);
    } else {
      // Add new exercise
      const exerciseWithId: Exercise = {
        ...newExercise,
        id: Date.now().toString(), // Simple ID generation
      };
      dispatch({
        type: 'add',
        exercise: exerciseWithId,
        group: exerciseWithId.group || 'primary',
      });
    }
  };

  const handleRemoveExercise = (exerciseId: string): void => {
    dispatch({ type: 'remove', exerciseId });
  };

  const handleEditExercise = (exerciseId: string): void => {
    setEditingExerciseId(exerciseId);
  };

  const handleSaveWorkout = (): void => {
    if (!name.trim()) {
      alert('Please enter a workout name.');
      return;
    }

    const totalExerciseCount = Object.values(exerciseGroups).reduce(
      (total, exercises) => total + exercises.length,
      0
    );

    if (totalExerciseCount === 0) {
      alert('Please add at least one exercise before creating the workout.');
      return;
    }

    const scheduleData = {
      name: name.trim(),
      workouts: [
        {
          day: 1,
          exercises: exerciseGroups,
        },
      ],
    };

    console.log('Creating schedule:', scheduleData);
    // TODO: Make POST request to backend API
  };

  const handleClearAll = (): void => {
    throw new Error('Not implemented yet');
  };

  const getExerciseById = (id: string): Exercise | undefined => {
    for (const group in exerciseGroups) {
      const exercise = exerciseGroups[group as Group]?.find(
        (ex) => ex.id === id
      );
      if (exercise) return exercise;
    }
    return undefined;
  };

  return (
    <div className="container py-4" style={{ maxWidth: '800px' }}>
      <div className="card shadow-sm">
        <div className="card-header bg-primary text-white">
          <h4 className="mb-0">Create New Workout</h4>
        </div>
        <div className="card-body border-bottom">
          <div className="mb-3">
            <label htmlFor="workoutName" className="form-label fw-bold">
              Workout Name
            </label>
            <input
              type="text"
              className="form-control"
              id="workoutName"
              value={name}
              onChange={(e) => setSchedule(e.target.value)}
              placeholder="Enter workout name (e.g., Week 1, Upper Body Split)"
              required
            />
          </div>
        </div>
        <div className="card-body">
          {/* Exercise Form - Using your existing ExerciseForm */}
          <div className="mb-4">
            <h5 className="mb-3">
              {editingExerciseId ? 'Edit Exercise' : 'Add Exercise'}
            </h5>
            <ExerciseForm
              onSubmit={handleAddExercise}
              initialExercise={
                editingExerciseId
                  ? getExerciseById(editingExerciseId)
                  : undefined
              }
              isEditing={editingExerciseId !== null}
              key={editingExerciseId || 'new'} // Force re-render when switching between edit/add
            />
          </div>
          <div className="mb-4">
            {groupOrder.map((group) => {
              const exercises = exerciseGroups[group];
              if (!exercises) return null;
              return (
                <div key={group} className="mb-4">
                  <ExerciseList
                    group={group}
                    exercises={exercises}
                    onRemoveExercise={handleRemoveExercise}
                    onEditExercise={handleEditExercise}
                  />
                </div>
              );
            })}
          </div>
          <div className="d-flex justify-content-end gap-2">
            <button
              className="btn btn-outline-secondary"
              onClick={handleClearAll}
              disabled={Object.keys(exerciseGroups).length === 0}
            >
              Clear All
            </button>
            <button
              className="btn btn-success"
              onClick={handleSaveWorkout}
              disabled={
                !name.trim() || Object.keys(exerciseGroups).length === 0
              }
            >
              Create Schedule
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreateWorkoutForm;
