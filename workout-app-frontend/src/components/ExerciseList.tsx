import type {Exercise} from "../types/Exercise.ts";

interface ExerciseListProps {
  exercises: Exercise[];
  onRemoveExercise: (exerciseId: string) => void;
  onEditExercise: (exerciseId: string) => void;
}

const ExerciseList: React.FC<ExerciseListProps> = ({ exercises, onRemoveExercise, onEditExercise }) => {
  if (exercises.length === 0) {
    return (
      <div className="text-muted text-center py-3 border rounded bg-light">
        <small>No exercises added yet. Use the form above to add your first exercise.</small>
      </div>
    );
  }

  return (
    <div className="border rounded bg-white">
      <div className="px-3 py-2 bg-light border-bottom">
        <h6 className="mb-0 fw-bold">Added Exercises ({exercises.length})</h6>
      </div>
      <div className="list-group list-group-flush">
        {exercises.map((exercise, index) => (
          <div key={exercise.id} className="list-group-item">
            <div className="d-flex justify-content-between align-items-start">
              <div className="flex-grow-1">
                <div className="d-flex align-items-center gap-2 mb-1">
                  <span className="badge bg-secondary rounded-pill small">{index + 1}</span>
                  <h6 className="mb-0 fw-bold">{exercise.name}</h6>
                </div>

                <div className="d-flex gap-3 text-muted small mb-1">
                  {exercise.sets && <span><strong>Sets:</strong> {exercise.sets}</span>}
                  {exercise.reps && <span><strong>Reps:</strong> {exercise.reps}</span>}
                  {exercise.weight && <span><strong>Weight:</strong> {exercise.weight}</span>}
                </div>

                {exercise.notes && (
                  <div className="text-muted small">
                    <strong>Notes:</strong> {exercise.notes}
                  </div>
                )}
              </div>

              <div className="d-flex gap-1">
                <button
                  className="btn btn-outline-secondary btn-sm"
                  onClick={() => exercise.id && onEditExercise(exercise.id)}
                  title="Edit exercise"
                >
                  ✏️
                </button>
                <button
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