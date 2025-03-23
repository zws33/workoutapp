let userId = localStorage.getItem('userId');

const apiUrl = 'https://workout-app-951785297505.us-east1.run.app';

async function startAuth() {
  try {
    const response = await fetch(`${apiUrl}/api/auth/google`);
    const data = await response.json();
    window.location.href = data.url;
  } catch (error) {
    document.getElementById('response').textContent = `Error: ${error.message}`;
  }
}

async function listSheets() {
  console.log(userId);
  if (!userId) {
    document.getElementById('response').textContent =
      'Please authenticate first!';
    return;
  }

  try {
    const response = await fetch(`${apiUrl}/api/sheets/list`, {
      headers: {
        'user-id': userId,
      },
    });
    const data = await response.json();
    const sheetsList = document.getElementById('sheetsList');
    sheetsList.innerHTML = '';
    data.sheets.forEach((sheet) => {
      const li = document.createElement('li');
      li.textContent = sheet.name;
      li.onclick = () => getWorkoutData(sheet.id);
      sheetsList.appendChild(li);
    });
  } catch (error) {
    document.getElementById('response').textContent = `Error: ${error.message}`;
  }
}

async function getWorkoutData(sheetId) {
  if (!userId) {
    document.getElementById('response').textContent =
      'Please authenticate first!';
    return;
  }

  if (!sheetId) {
    sheetId = document.getElementById('sheetId').value;
    if (!sheetId) {
      document.getElementById('response').textContent =
        'Please enter a Sheet ID!';
      return;
    }
  }

  try {
    const response = await fetch(`${apiUrl}/api/workouts/${sheetId}`, {
      headers: {
        'user-id': userId,
      },
    });
    const data = await response.json();
    renderWorkoutData(data.workouts);
  } catch (error) {
    document.getElementById('response').textContent = `Error: ${error.message}`;
  }
}

function renderWorkoutData(workouts) {
  const tbody = document
    .getElementById('responseTable')
    .getElementsByTagName('tbody')[0];
  tbody.innerHTML = ''; // Clear existing data

  workouts.forEach((workout) => {
    const row = tbody.insertRow();
    row.insertCell().textContent = workout.day;
    row.insertCell().textContent = workout.name;
    row.insertCell().textContent = workout.sets;
    row.insertCell().textContent = workout.reps || '';
    row.insertCell().textContent = workout.weight || '';
    row.insertCell().textContent = workout.notes || '';
  });
}

// Check if we're returning from OAuth
const urlParams = new URLSearchParams(window.location.search);
const userIdFromUrl = urlParams.get('userId');
if (userIdFromUrl) {
  localStorage.setItem('userId', userIdFromUrl);
  userId = userIdFromUrl;
  document.getElementById('response').textContent =
    'Authentication successful! UserId stored.';
}
