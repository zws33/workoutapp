import React, { useState } from 'react';
import type { Exercise, Group } from '../types/Exercise.ts';

interface ExerciseFormProps {
  onSubmit: (exercise: Exercise) => void;
  initialExercise?: Exercise;
  isEditing?: boolean;
}

// Initial data for a new exercise
const initialData: Exercise = {
  group: 'primary' as Group,
  name: '',
  sets: 1,
  reps: null,
  weight: null,
  notes: null,
};

const ExerciseForm: React.FC<ExerciseFormProps> = ({
  onSubmit,
  initialExercise = { ...initialData },
  isEditing = false,
}) => {
  // State to manage validation errors
  const [errors, setErrors] = useState<{ [key: string]: string }>({});

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const formData = new FormData(e.currentTarget);
    const newErrors: { [key: string]: string } = {};

    const name = (formData.get('name') as string)?.trim() || '';
    const group = (formData.get('group') as Group) || 'primary';
    const setsRaw = (formData.get('sets') as string)?.trim();
    const repsRaw = (formData.get('reps') as string)?.trim();
    const weight = (formData.get('weight') as string)?.trim() || null;
    const notes = (formData.get('notes') as string)?.trim() || null;

    // Validate Exercise Name
    if (!name) {
      newErrors.name = 'Exercise name is required';
    }

    // Validate Sets
    let sets: number = initialExercise.sets || 1;
    if (!setsRaw) {
      newErrors.sets = 'Sets is required.';
    } else {
      const parsedSets = parseInt(setsRaw, 10);
      if (isNaN(parsedSets)) {
        newErrors.sets = 'Sets must be a number.';
      } else if (parsedSets < 1) {
        newErrors.sets = 'Sets must be at least 1.';
      }
      sets = parsedSets; // Assign valid parsed sets
    }

    // Validate Reps (can be null or a number)
    let reps: number | null = null;
    if (repsRaw) {
      // Only parse if reps input has a value
      const parsedReps = parseInt(repsRaw, 10);
      if (isNaN(parsedReps)) {
        // Invalid reps values are treated as null to indicate no input or invalid input
        reps = null;
      } else {
        reps = parsedReps;
      }
    }

    // Update the errors state
    setErrors(newErrors);

    // If there are any errors, stop the submission
    if (Object.keys(newErrors).length > 0) {
      console.log('Validation errors:', newErrors);
      return;
    }

    // Construct the Exercise object to submit
    const submittedExercise: Exercise = {
      // If editing, preserve the existing ID; otherwise, it will be undefined
      ...(isEditing && initialExercise.id && { id: initialExercise.id }),
      group,
      name,
      sets,
      reps,
      weight,
      notes,
    };

    // Call the onSubmit prop with the validated exercise data
    onSubmit(submittedExercise);

    // If not in editing mode, reset the form fields and clear errors
    if (!isEditing) {
      e.currentTarget.reset(); // Resets all form elements to their initial values
      setErrors({}); // Clear any previous validation errors
    }
  };

  return (
    <form onSubmit={handleSubmit} className="border rounded p-2 bg-light">
      {/* Row 1: Name and Group */}
      <div className="row g-2 mb-1">
        <div className="col-md-8">
          <label htmlFor="name" className="form-label fw-bold mb-1 small">
            Exercise
          </label>
          <input
            type="text"
            className={`form-control form-control-sm ${
              errors.name ? 'is-invalid' : ''
            }`}
            id="name"
            name="name"
            defaultValue={initialExercise.name}
            placeholder="Exercise name"
            aria-label="Exercise name"
          />
          {errors.name && <div className="invalid-feedback">{errors.name}</div>}
        </div>
        <div className="col-md-4">
          <label htmlFor="group" className="form-label fw-bold mb-1 small">
            Group
          </label>
          <select
            className="form-select form-select-sm"
            id="group"
            name="group"
            defaultValue={initialExercise.group}
            aria-label="Exercise group category"
          >
            <option value="primary">Primary</option>
            <option value="secondary">Secondary</option>
            <option value="cardio">Cardio</option>
            <option value="core">Core</option>
          </select>
        </div>
      </div>

      {/* Row 2: Sets, Reps, Weight */}
      <div className="row g-2 mb-1">
        <div className="col-4">
          <div className="input-group input-group-sm">
            <span className="input-group-text fw-bold small">Sets</span>
            <input
              type="number"
              className={`form-control form-control-sm ${
                errors.sets ? 'is-invalid' : ''
              }`}
              id="sets"
              name="sets"
              defaultValue={initialExercise.sets ?? ''}
              placeholder="3"
              min="1"
              max="999"
              aria-label="Number of sets"
            />
            {errors.sets && (
              <div className="invalid-feedback">{errors.sets}</div>
            )}
          </div>
        </div>
        <div className="col-4">
          <div className="input-group input-group-sm">
            <span className="input-group-text fw-bold small">Reps</span>
            <input
              type="number"
              className="form-control form-control-sm"
              id="reps"
              name="reps"
              defaultValue={initialExercise.reps ?? ''}
              placeholder="10"
              min="0"
              max="999"
              aria-label="Number of repetitions"
            />
          </div>
        </div>
        <div className="col-4">
          <div className="input-group input-group-sm">
            <span className="input-group-text fw-bold small">Weight</span>
            <input
              type="text"
              className="form-control form-control-sm"
              id="weight"
              name="weight"
              defaultValue={initialExercise.weight ?? ''}
              placeholder="135 lbs"
              aria-label="Weight amount"
            />
          </div>
        </div>
      </div>

      {/* Row 3: Notes and Submit Button */}
      <div className="row g-2 align-items-end">
        <div className="col-md-8">
          <label htmlFor="notes" className="form-label fw-bold mb-1 small">
            Notes
          </label>
          <input
            type="text"
            className="form-control form-control-sm"
            id="notes"
            name="notes"
            defaultValue={initialExercise.notes ?? ''}
            placeholder="Notes (optional)"
            aria-label="Exercise notes"
          />
        </div>
        <div className="col-md-4">
          <button
            type="submit"
            className="btn btn-primary btn-sm w-100 fw-bold"
          >
            {isEditing ? 'Update Exercise' : 'Add Exercise'}
          </button>
        </div>
      </div>
    </form>
  );
};

export default ExerciseForm;
