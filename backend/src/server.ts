import express from 'express';
import dotenv from 'dotenv';
import { GoogleSheetsService } from './googleSheetsService';
import { verifyToken } from './authenticate';
import { getWorkoutDb } from './workoutDb';
import { WorkoutRepository } from './workoutRepository';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

const sheetId = process.env.GOOGLE_SHEET_ID;
if (!sheetId) {
  throw new Error('GOOGLE_SHEET_ID environment variable not set');
}

const sheetsService = new GoogleSheetsService(sheetId);
const workoutDb = getWorkoutDb();
const repository = new WorkoutRepository(sheetsService, workoutDb);
repository.startCronJob();

app.get('/api/sheets', verifyToken, async (req, res) => {
  try {
    const sheetNames = await sheetsService.getSheetNames();
    res.json(sheetNames);
  } catch (error) {
    console.error('Error getting sheet names:', error);
    res.status(500).json({ error: 'Failed to fetch sheet names' });
  }
});

app.get('/api/sheets/:sheetName', verifyToken, async (req, res) => {
  const { sheetName } = req.params;
  try {
    const data = await sheetsService.getSheetData(sheetName);
    res.json(data);
  } catch (error) {
    console.error(`Error getting data from sheet ${sheetName}:`, error);
    res
      .status(500)
      .json({ error: `Failed to fetch data from sheet ${sheetName}` });
  }
});

app.get('/api/workouts/:week', verifyToken, async (req, res) => {
  const { week } = req.params;
  try {
    const data = await repository.getWorkoutData(week);
    res.json(data);
  } catch (error) {
    console.error(`Error getting data for ${week}:`, error);
    res.status(500).json({ error: `Failed to fetch data for ${week}` });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
