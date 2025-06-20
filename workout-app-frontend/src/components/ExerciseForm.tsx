import React, { useState, useCallback } from "react";
import type {Exercise, Group} from "../types/Exercise";

interface ExerciseFormProps {
  onSubmit: (exercise: Exercise) => void;
  initialExercise?: Exercise;
  isEditing?: boolean;
}
const defaultData: Exercise = {
  group: "primary" as Group,
  name: "",
  sets: null,
  reps: null,
  weight: "",
  notes: "",
};
const ExerciseForm: React.FC<ExerciseFormProps> = ({
  onSubmit,
  initialExercise = {...defaultData},
  isEditing = false
}) => {
  const [exercise, setExercise] = useState<Exercise>(initialExercise);
  const [errors, setErrors] = useState<{[key: string]: string}>({});

  const handleChange = useCallback((
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>,
  ) => {
    const { name, value } = e.target;

    // Clear error for this field when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    setExercise((prev) => {
      const newExercise = {
        ...prev,
        [name]:
          name === "sets" || name === "reps"
            ? value === ""
              ? null
              : parseInt(value, 10) || null
            : value,
      };
      return newExercise;
    });
  }, [errors]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validate form
    const newErrors: {[key: string]: string} = {};
    if (!exercise.name.trim()) {
      newErrors.name = 'Exercise name is required';
    }
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    
    onSubmit(exercise);
    if (!isEditing) {
      setExercise({...defaultData});
      setErrors({});
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
            className={`form-control form-control-sm ${errors.name ? 'is-invalid' : ''}`}
            id="name"
            name="name"
            value={exercise.name}
            onChange={handleChange}
            required
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
            value={exercise.group}
            onChange={handleChange}
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
              className="form-control form-control-sm"
              id="sets"
              name="sets"
              value={exercise.sets === null ? "" : exercise.sets}
              onChange={handleChange}
              placeholder="3"
              min="1"
              max="999"
              aria-label="Number of sets"
            />
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
              value={exercise.reps === null ? "" : exercise.reps}
              onChange={handleChange}
              placeholder="10"
              min="1"
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
              value={exercise.weight}
              onChange={handleChange}
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
            value={exercise.notes}
            onChange={handleChange}
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
