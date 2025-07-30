let userId = localStorage.getItem("userId");

// Determine environment (default to development)
const isProd = window.location.hostname !== "localhost";
const apiUrl = isProd
  ? "https://workout-app-951785297505.us-east1.run.app"
  : "http://localhost:3000";

async function startAuth() {
  try {
    const response = await fetch(`${apiUrl}/api/auth/google`);
    const data = await response.json();
    window.location.href = data.url;
  } catch (error) {
    alert(`Error: ${error.message}`);
  }
}

async function listSheets() {
  if (!userId) {
    alert("Please authenticate first!");
    return;
  }

  try {
    const response = await fetch(`${apiUrl}/api/sheets/list`, {
      headers: {
        "user-id": userId,
      },
    });
    const data = await response.json();
    const sheetsList = document.getElementById("sheetsList");
    sheetsList.innerHTML = "";
    data.sheets.forEach((sheet) => {
      const li = document.createElement("li");
      li.textContent = sheet.name;
      li.onclick = () => getWorkoutData(sheet.id);
      sheetsList.appendChild(li);
    });
  } catch (error) {
    alert(`Error: ${error.message}`);
  }
}

function filterWorkouts() {
  const selectedDay = document.getElementById("dayFilter").value.toLowerCase();
  const allWorkouts = JSON.parse(localStorage.getItem("allWorkouts")) || [];

  const filteredWorkouts =
    selectedDay === "all"
      ? allWorkouts
      : allWorkouts.filter(
          (workout) => workout.day.toLowerCase() === selectedDay,
        );

  renderWorkoutData(filteredWorkouts);
}

async function getWorkoutData(sheetId) {
  if (!userId) {
    alert("Please authenticate first!");
    return;
  }

  try {
    const response = await fetch(`${apiUrl}/api/workouts/${sheetId}`, {
      headers: {
        "user-id": userId,
      },
    });
    const data = await response.json();
    localStorage.setItem("allWorkouts", JSON.stringify(data.workouts)); // Store all workouts
    renderWorkoutData(data.workouts);
  } catch (error) {
    alert(`Error: ${error.message}`);
  }
}

function renderWorkoutData(workouts) {
  const tbody = document
    .getElementById("responseTable")
    .getElementsByTagName("tbody")[0];
  tbody.innerHTML = ""; // Clear existing data

  workouts.forEach((workout) => {
    const row = tbody.insertRow();
    row.insertCell().textContent = workout.name;
    row.insertCell().textContent = workout.sets;
    row.insertCell().textContent = workout.reps || "";
    row.insertCell().textContent = workout.weight || "";
    row.insertCell().textContent = workout.notes || "";
  });
}

// Check if we're returning from OAuth
const urlParams = new URLSearchParams(window.location.search);
const userIdFromUrl = urlParams.get("userId");
if (userIdFromUrl) {
  localStorage.setItem("userId", userIdFromUrl);
  userId = userIdFromUrl;
  alert("Authentication successful! UserId stored.");
}
