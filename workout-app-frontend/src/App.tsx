import { useState } from 'react'
import './App.css'
import ExerciseForm from './components/ExerciseForm'
import type { Exercise } from './types/Exercise'

function App() {
  const [exercises, setExercises] = useState<Exercise[]>([])

  const handleExerciseSubmit = (exercise: Exercise) => {
    setExercises(prev => [...prev, exercise])
    console.log('Exercise added:', exercise)
  }

  return (
    <div className="app-container">
      <header>
        <h1>Workout App</h1>
      </header>
      <main>
        <ExerciseForm onSubmit={handleExerciseSubmit} />

        {exercises.length > 0 && (
          <div className="exercises-list">
            <h2>Added Exercises</h2>
            <ul>
              {exercises.map((exercise, index) => (
                <li key={index}>
                  <strong>{exercise.name}</strong>
                  {exercise.sets !== undefined && exercise.reps !== undefined && (
                    <span> - {exercise.sets} sets x {exercise.reps} reps</span>
                  )}
                  {exercise.weight && <span> {exercise.weight}</span>}
                  {exercise.notes && <p className="exercise-notes">{exercise.notes}</p>}
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
