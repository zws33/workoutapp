import React from 'react';
import ScheduleForm from './components/ScheduleForm.tsx';

function App() {
  return (
    <div className="container py-4">
      <header className="mb-4 text-center">
        <h1 className="text-primary">Workout App</h1>
      </header>
      <main className="d-flex flex-column gap-4">
        <ScheduleForm />
      </main>
    </div>
  );
}

export default App;
