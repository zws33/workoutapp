import { useState } from 'react';
import type { Exercise } from '../types/Exercise';
import './ExerciseForm.css';

interface ExerciseFormProps {
  onSubmit: (exercise: Exercise) => void;
  initialExercise?: Exercise;
}

const ExerciseForm: React.FC<ExerciseFormProps> = ({ 
  onSubmit, 
  initialExercise = { name: '', sets: undefined, reps: undefined, weight: '', notes: '' }
}) => {
  const [exercise, setExercise] = useState<Exercise>(initialExercise);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;

    setExercise(prev => ({
      ...prev,
      [name]: name === 'sets' || name === 'reps' 
        ? value === '' ? null : parseInt(value) || 0 
        : value
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(exercise);
    setExercise({ name: '', sets: undefined, reps: undefined, weight: '', notes: '' });
  };

  return (
    <form onSubmit={handleSubmit} className="exercise-form">
      <h2>Add Exercise</h2>

      <div className="form-group">
        <label htmlFor="name">Exercise Name</label>
        <input
          type="text"
          id="name"
          name="name"
          value={exercise.name}
          onChange={handleChange}
          required
          placeholder="e.g., Bench Press"
        />
      </div>

      <div className="form-group">
        <label htmlFor="sets">Sets</label>
        <input
          type="number"
          id="sets"
          name="sets"
          value={exercise.sets === null ? '' : exercise.sets}
          onChange={handleChange}
          placeholder="e.g. 3"
        />
      </div>

      <div className="form-group">
        <label htmlFor="reps">Reps</label>
        <input
          type="number"
          id="reps"
          name="reps"
          value={exercise.reps === null ? '' : exercise.reps}
          onChange={handleChange}
          placeholder="e.g. 10"
        />
      </div>

      <div className="form-group">
        <label htmlFor="weight">Weight</label>
        <input
          type="text"
          id="weight"
          name="weight"
          value={exercise.weight}
          onChange={handleChange}
          placeholder="e.g., 135 lbs, Body weight"
        />
      </div>

      <div className="form-group">
        <label htmlFor="notes">Notes</label>
        <textarea
          id="notes"
          name="notes"
          value={exercise.notes}
          onChange={handleChange}
          placeholder="Any additional notes about the exercise"
          rows={3}
        />
      </div>

      <button type="submit" className="submit-button">Save Exercise</button>
    </form>
  );
};

export default ExerciseForm;
