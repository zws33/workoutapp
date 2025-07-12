import React from 'react';
import type { Exercise, Group } from '../types/Exercise.ts';

interface ExerciseListProps {
  group: Group;
  exercises: Exercise[];
  onRemoveExercise: (exerciseId: string) => void;
  onEditExercise: (exerciseId: string) => void;
}

const ExerciseList: React.FC<ExerciseListProps> = ({
  group,
  exercises,
  onRemoveExercise,
  onEditExercise,
}) => {
  if (exercises.length === 0) {
    return (
      <div className="text-muted text-center py-3 border rounded bg-light">
        <small>
          No exercises added yet. Use the form above to add your first exercise.
        </small>
      </div>
    );
  }

  return (
    <div className="border rounded bg-white">
      <div className="px-3 py-2 bg-light border-bottom">
        <h6 className="mb-0 fw-bold">{group.toUpperCase()}</h6>
      </div>
      <div className="list-group list-group-flush">
        {exercises.map((exercise) => (
          <div key={exercise.id} className="list-group-item">
            <div className="d-flex justify-content-between align-items-start">
              <div className="flex-grow-1">
                <div className="d-flex align-items-center gap-2 mb-1">
                  <h6 className="mb-0 fw-bold">{exercise.name}</h6>
                  {exercise.sets && (
                    <span>
                      <strong>Sets:</strong> {exercise.sets}
                    </span>
                  )}
                  {exercise.reps && (
                    <span>
                      <strong>Reps:</strong> {exercise.reps}
                    </span>
                  )}
                  {exercise.weight && (
                    <span>
                      <strong>Weight:</strong> {exercise.weight}
                    </span>
                  )}
                </div>
                {exercise.notes && (
                  <div className="text-muted small">
                    <strong>Notes:</strong> {exercise.notes}
                  </div>
                )}
              </div>

              <div className="d-flex gap-1">
                <button
                  type="button"
                  className="btn btn-outline-secondary btn-sm"
                  onClick={() => exercise.id && onEditExercise(exercise.id)}
                  title="Edit exercise"
                >
                  ✏️
                </button>
                <button
                  type="button"
                  className="btn btn-outline-danger btn-sm"
                  onClick={() => exercise.id && onRemoveExercise(exercise.id)}
                  title="Remove exercise"
                >
                  🗑️
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ExerciseList;
