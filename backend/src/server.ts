import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import { GoogleSheetsService } from './googleSheetsService.js';
import { authenticateUser } from './authenticate.js';
import { getWorkoutDb } from './workoutDb.js';
import { WorkoutRepository } from './workoutRepository.js';
import { getErrorMessage } from './utils.js';

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration
const corsOptions = {
  origin: [
    'http://localhost:5173', // Vite dev server
    'http://localhost:3000', // Alternative dev port
    'https://your-frontend-domain.com', // Replace with your production domain
  ],
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(corsOptions));
app.use(express.json());
app.use(express.static('public'));

const sheetId = process.env.GOOGLE_SHEET_ID;
if (!sheetId) {
  throw new Error('GOOGLE_SHEET_ID environment variable not set');
}

const sheetsService = new GoogleSheetsService(sheetId);
const workoutDb = getWorkoutDb();
const repository = new WorkoutRepository(sheetsService, workoutDb);
await repository.syncWorkoutData();
repository.startCronJob();

app.get('/api/schedules', authenticateUser, async (req, res) => {
  try {
    const schedules = await repository.getSchedules();
    res.json({
      success: true,
      data: schedules,
      count: schedules.length,
    });
  } catch (e) {
    console.error('Error getting workouts:', e);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch workouts',
      message: getErrorMessage(e),
    });
  }
});

app.post('/api/schedules', authenticateUser, async (req, res) => {
  try {
    const { name, workouts } = req.body;

    // Basic validation
    if (!name || !workouts) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: [
          ...(name
            ? []
            : [{ field: 'name', message: 'Schedule name is required' }]),
          ...(workouts
            ? []
            : [{ field: 'workouts', message: 'Workouts array is required' }]),
        ],
      });
    }

    const schedule = await repository.createSchedule({ name, workouts });

    res.status(201).json({
      success: true,
      data: schedule,
    });
  } catch (e) {
    const errorMessage = getErrorMessage(e);
    console.error('Error creating schedule:', e);

    // Handle specific error cases
    if (errorMessage.includes('already exists')) {
      return res.status(409).json({
        success: false,
        error: errorMessage,
        code: 'SCHEDULE_EXISTS',
      });
    }

    if (
      errorMessage.includes('required') ||
      errorMessage.includes('must have')
    ) {
      return res.status(400).json({
        success: false,
        error: errorMessage,
        code: 'VALIDATION_ERROR',
      });
    }

    res.status(500).json({
      success: false,
      error: 'Failed to create schedule',
      message: errorMessage,
    });
  }
});

app.get('/api/workouts/:week', authenticateUser, async (req, res) => {
  const { week } = req.params;
  try {
    const data = await repository.getScheduleByName(week);
    res.json(data);
  } catch (error) {
    console.error(`Error getting data for ${week}:`, error);
    res.status(500).json({ error: `Failed to fetch data for ${week}` });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
