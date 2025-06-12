import React, { useState } from 'react';
import type {Exercise} from "../types/Exercise.ts";
import ExerciseForm from './ExerciseForm';
import ExerciseList from './ExerciseList.tsx';
const CreateWorkoutForm: React.FC = () => {
  const [exercises, setExercises] = useState<Exercise[]>([]);

  const handleAddExercise = (newExercise: Exercise): void => {
    const exerciseWithId: Exercise = {
      ...newExercise,
      id: Date.now().toString() // Simple ID generation
    };
    setExercises(prev => [...prev, exerciseWithId]);
  };

  const handleRemoveExercise = (exerciseId: string): void => {
    setExercises(prev => prev.filter(ex => ex.id !== exerciseId));
  };

  const handleEditExercise = (exerciseId: string): void => {
    // TODO: Implement edit functionality
    console.log('Edit exercise:', exerciseId);
  };

  const handleSaveWorkout = (): void => {
    if (exercises.length === 0) {
      alert('Please add at least one exercise before saving.');
      return;
    }

    // TODO: Implement save workout logic
    console.log('Saving workout with exercises:', exercises);
    alert(`Workout saved with ${exercises.length} exercises!`);
  };

  const handleClearAll = (): void => {
    setExercises([]);
  };

  return (
    <div className="container py-4" style={{ maxWidth: '800px' }}>
  <div className="card shadow-sm">
  <div className="card-header bg-primary text-white">
  <h4 className="mb-0">Create New Workout</h4>
  </div>
  <div className="card-body">
    {/* Exercise Form - Using your existing ExerciseForm */}
    <div className="mb-4">
  <h5 className="mb-3">Add Exercise</h5>
  <ExerciseForm onSubmit={handleAddExercise} />
  </div>
  <div className="mb-4">
  <ExerciseList
    exercises={exercises}
  onRemoveExercise={handleRemoveExercise}
  onEditExercise={handleEditExercise}
  />
  </div>

  {/* Save Workout Button */}
  <div className="d-flex justify-content-end gap-2">
  <button
    className="btn btn-outline-secondary"
  onClick={handleClearAll}
  disabled={exercises.length === 0}
    >
    Clear All
  </button>
  <button
  className="btn btn-success"
  onClick={handleSaveWorkout}
  disabled={exercises.length === 0}
    >
    Save Workout ({exercises.length} exercises)
  </button>
  </div>
  </div>
  </div>
  </div>
);
};

// Note: You'll need to import your existing ExerciseForm component
// import ExerciseForm from './ExerciseForm';

export default CreateWorkoutForm;