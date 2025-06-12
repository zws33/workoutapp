import { useState } from 'react'
import ExerciseForm from './components/ExerciseForm'
import type { Exercise } from './types/Exercise'

function App() {
  const [exercises, setExercises] = useState<Exercise[]>([])

  const handleExerciseSubmit = (exercise: Exercise) => {
    setExercises(prev => [...prev, exercise])
    console.log('Exercise added:', exercise)
  }

  return (
    <div className="container py-4">
      <header className="mb-4 text-center">
        <h1 className="text-primary">Workout App</h1>
      </header>
      <main className="d-flex flex-column gap-4">
        <ExerciseForm onSubmit={handleExerciseSubmit} />

        {exercises.length > 0 && (
          <div className="card p-4 bg-light shadow-sm mx-auto" style={{ maxWidth: '500px' }}>
            <h2 className="text-center mb-3">Added Exercises</h2>
            <ul className="list-group list-group-flush">
              {exercises.map((exercise, index) => (
                <li key={index} className="list-group-item px-3 py-3">
                  <strong>{exercise.name}</strong>
                  {exercise.sets !== undefined && exercise.reps !== undefined && (
                    <span> - {exercise.sets} sets x {exercise.reps} reps</span>
                  )}
                  {exercise.weight && <span> {exercise.weight}</span>}
                  {exercise.notes && <p className="mt-2 small text-muted fst-italic">{exercise.notes}</p>}
                </li>
              ))}
            </ul>
          </div>
        )}
      </main>
    </div>
  )
}

export default App
