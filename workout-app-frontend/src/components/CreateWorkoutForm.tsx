import React, { useReducer, useState } from 'react';
import type { Exercise, Group, ExerciseGroups, Workout } from '../types/Exercise.ts';
import ExerciseForm from './ExerciseForm.tsx';
import ExerciseList from './ExerciseList.tsx';

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

interface CreateWorkoutFormProps {
  initialWorkout?: Workout;
  workoutDay: number;
  onSave: (workout: Workout) => void;
  onCancel: () => void;
  isEditing?: boolean;
}

const CreateWorkoutForm: React.FC<CreateWorkoutFormProps> = ({
  initialWorkout,
  workoutDay,
  onSave,
  onCancel,
  isEditing = false,
}) => {
  const [exerciseGroups, dispatch] = useReducer(
    reducer,
    initialWorkout?.exercises || ({} as ExerciseGroups)
  );
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
    const totalExerciseCount = Object.values(exerciseGroups).reduce(
      (total, exercises) => total + exercises.length,
      0
    );

    if (totalExerciseCount === 0) {
      alert('Please add at least one exercise before creating the workout.');
      return;
    }

    const workout: Workout = {
      id: initialWorkout?.id,
      day: workoutDay,
      exercises: exerciseGroups,
    };

    onSave(workout);
  };

  const handleClearAll = (): void => {
    dispatch({ type: 'cancel_edit' });
    // Reset to empty state
    Object.keys(exerciseGroups).forEach(() => {
      // Clear all exercises by removing them one by one
      Object.values(exerciseGroups).flat().forEach(exercise => {
        if (exercise.id) {
          dispatch({ type: 'remove', exerciseId: exercise.id });
        }
      });
    });
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
        <div className="card-header bg-primary text-white d-flex justify-content-between align-items-center">
          <h4 className="mb-0">{isEditing ? 'Edit' : 'Create'} Workout - Day {workoutDay}</h4>
          <button
            className="btn btn-outline-light btn-sm"
            onClick={onCancel}
            title="Cancel and go back"
          >
            ← Back
          </button>
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
          <div className="d-flex justify-content-between">
            <button
              className="btn btn-outline-secondary"
              onClick={handleClearAll}
              disabled={Object.keys(exerciseGroups).length === 0}
            >
              Clear All
            </button>
            <div className="d-flex gap-2">
              <button
                className="btn btn-outline-secondary"
                onClick={onCancel}
              >
                Cancel
              </button>
              <button
                className="btn btn-success"
                onClick={handleSaveWorkout}
                disabled={Object.keys(exerciseGroups).length === 0}
              >
                {isEditing ? 'Update' : 'Save'} Workout
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreateWorkoutForm;
