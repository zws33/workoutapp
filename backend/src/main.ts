import express from 'express';
import { GoogleSheetsService } from './googleSheetsService.ts';
import { verifyToken } from './authenticate.ts';
import { firestore } from './firstoreDb.ts';
import { WorkoutRepository } from './workoutRepository.ts';

const PORT = Deno.env.get('PORT') || 3000;
const app = express();
app.use(express.json());

app.use(express.static('public'));

const sheetId = Deno.env.get('GOOGLE_SHEET_ID');
if (!sheetId) {
  throw new Error('GOOGLE_SHEET_ID environment variable not set');
}

const sheetsService = new GoogleSheetsService(sheetId);
let repository: WorkoutRepository;
try {
  const db = await firestore();
  const result = await db.collection('workouts').doc('Week 1').get();
  console.log(result.data);
  repository = new WorkoutRepository(sheetsService, db);
} catch (error) {
  console.error('Error initializing Firestore:', error);
  throw new Error('Failed to initialize Firestore');
}

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
