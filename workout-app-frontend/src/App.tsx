import CreateWorkoutForm from "./components/CreateWorkoutForm.tsx";

function App() {
  return (
    <div className="container py-4">
      <header className="mb-4 text-center">
        <h1 className="text-primary">Workout App</h1>
      </header>
      <main className="d-flex flex-column gap-4">
        <CreateWorkoutForm/>
      </main>
    </div>
  )
}

export default App
