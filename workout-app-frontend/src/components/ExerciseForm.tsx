import {useState} from 'react';
import type {Exercise} from '../types/Exercise';

interface ExerciseFormProps {
  onSubmit: (exercise: Exercise) => void;
  initialExercise?: Exercise;
}

const ExerciseForm: React.FC<ExerciseFormProps> = (
  {
    onSubmit,
    initialExercise = {
      name: '',
      sets: undefined,
      reps: undefined,
      weight: '',
      notes: ''
    }
  }) => {
  const [exercise, setExercise] = useState<Exercise>(initialExercise);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const {name, value} = e.target;

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
    setExercise({name: '', sets: undefined, reps: undefined, weight: '', notes: ''});
  };

  return (
    <form onSubmit={handleSubmit} className="border rounded p-2 bg-light">
      <div className="row g-1 align-items-end">
        <div className="col-md-3">
          <label htmlFor="name" className="form-label fw-bold mb-1 small">Exercise</label>
          <input
            type="text"
            className="form-control form-control-sm"
            id="name"
            name="name"
            value={exercise.name}
            onChange={handleChange}
            required
            placeholder="Exercise name"
          />
        </div>
        <div className="col-md-2 col-3">
          <label htmlFor="sets" className="form-label fw-bold mb-1 small">Sets</label>
          <input
            type="number"
            className="form-control form-control-sm"
            id="sets"
            name="sets"
            value={exercise.sets === null ? '' : exercise.sets}
            onChange={handleChange}
            placeholder="3"
          />
        </div>
        <div className="col-md-2 col-3">
          <label htmlFor="reps" className="form-label fw-bold mb-1 small">Reps</label>
          <input
            type="number"
            className="form-control form-control-sm"
            id="reps"
            name="reps"
            value={exercise.reps === null ? '' : exercise.reps}
            onChange={handleChange}
            placeholder="10"
          />
        </div>
        <div className="col-md-2 col-3">
          <label htmlFor="weight" className="form-label fw-bold mb-1 small">Weight</label>
          <input
            type="text"
            className="form-control form-control-sm"
            id="weight"
            name="weight"
            value={exercise.weight}
            onChange={handleChange}
            placeholder="135 lbs"
          />
        </div>
        <div className="col-md-3 col-3">
          <button type="submit" className="btn btn-primary btn-sm w-100 fw-bold">
            Add
          </button>
        </div>
      </div>
      <div className="row g-1 mt-1">
        <div className="col">
          <input
            type="text"
            className="form-control form-control-sm"
            id="notes"
            name="notes"
            value={exercise.notes}
            onChange={handleChange}
            placeholder="Notes (optional)"
          />
        </div>
      </div>
    </form>
  );
};

export default ExerciseForm;