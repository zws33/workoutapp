import { useState } from 'react';
import type { Exercise } from '../types/Exercise';

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
    <form onSubmit={handleSubmit} className="card p-3 bg-light shadow-sm mx-auto" style={{ maxWidth: '500px' }}>
      <h5 className="text-center mb-3">Add Exercise</h5>

      <div className="mb-2">
        <label htmlFor="name" className="form-label fw-bold mb-1">Exercise Name</label>
        <input
          type="text"
          className="form-control form-control-sm"
          id="name"
          name="name"
          value={exercise.name}
          onChange={handleChange}
          required
          placeholder="e.g., Bench Press"
        />
      </div>

      <div className="row g-2 mb-2">
        <div className="col-4">
          <label htmlFor="sets" className="form-label fw-bold mb-1">Sets</label>
          <input
            type="number"
            className="form-control form-control-sm"
            id="sets"
            name="sets"
            value={exercise.sets === null ? '' : exercise.sets}
            onChange={handleChange}
            placeholder="e.g. 3"
          />
        </div>
        <div className="col-4">
          <label htmlFor="reps" className="form-label fw-bold mb-1">Reps</label>
          <input
            type="number"
            className="form-control form-control-sm"
            id="reps"
            name="reps"
            value={exercise.reps === null ? '' : exercise.reps}
            onChange={handleChange}
            placeholder="e.g. 10"
          />
        </div>
        <div className="col-4">
          <label htmlFor="weight" className="form-label fw-bold mb-1">Weight</label>
          <input
            type="text"
            className="form-control form-control-sm"
            id="weight"
            name="weight"
            value={exercise.weight}
            onChange={handleChange}
            placeholder="e.g., 135 lbs"
          />
        </div>
      </div>

      <div className="mb-2">
        <label htmlFor="notes" className="form-label fw-bold mb-1">Notes</label>
        <textarea
          className="form-control form-control-sm"
          id="notes"
          name="notes"
          value={exercise.notes}
          onChange={handleChange}
          placeholder="Any additional notes"
          rows={2}
        />
      </div>

      <button type="submit" className="btn btn-primary btn-sm w-100 mt-1 fw-bold">Save Exercise</button>
    </form>
  );
};

export default ExerciseForm;
