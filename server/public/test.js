let userId = localStorage.getItem('userId');

async function startAuth() {
  try {
    const response = await fetch('http://localhost:3000/api/auth/google');
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
    const response = await fetch(`http://localhost:3000/api/sheets/list`, {
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
    const response = await fetch(
      `http://localhost:3000/api/workouts/${sheetId}`,
      {
        headers: {
          'user-id': userId,
        },
      }
    );
    const data = await response.json();
    document.getElementById('response').textContent = JSON.stringify(
      data,
      null,
      2
    );
  } catch (error) {
    document.getElementById('response').textContent = `Error: ${error.message}`;
  }
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
