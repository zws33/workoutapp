// server.ts
import express, { NextFunction } from 'express';
import { google } from 'googleapis';
import dotenv from 'dotenv';
import { OAuth2Client } from 'google-auth-library';
import { Request, Response } from 'express';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON requests
app.use(express.json());

// Serve static files from public directory
app.use(express.static('public'));

// Optional CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://localhost:5173'); // Replace with your frontend's origin
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, user-id'
  ); // Include Authorization header
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200); // Handle preflight requests
  }
  next();
});

// Determine environment (default to development)
const isProd = process.env.NODE_ENV === 'production';

const oauth2Client: OAuth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET
);

// Store tokens temporarily (in production, use a proper database)
const userTokens = new Map<string, any>();

// Interface for workout data
interface WorkoutData {
  type: string;
  exercise: string;
  sets: number;
  reps?: number;
  weight?: number;
  notes?: string;
}

const authenticate = async (req: any, res: any, next: any) => {
  const idToken = req.headers['authorization']?.split(' ')[1];
  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized: Missing token' });
  }
  try {
    const ticket = await oauth2Client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    if (!payload) {
      return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }
    req.user = {
      id: payload.sub,
      email: payload.email,
      name: payload.name,
    };
    next();
  } catch (error) {
    console.error('Error validating token:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
};

// Endpoint to list available Google Sheets in a specific folder
app.get('/api/sheets/list', authenticate, async (req, res) => {
  const userId = req.headers['user-id'] as string;
  const userToken = userTokens.get(userId);

  if (!userToken) {
    return res.status(401).json({ error: 'User not authenticated' });
  }

  try {
    oauth2Client.setCredentials(userToken);
    const drive = google.drive({ version: 'v3', auth: oauth2Client });

    const folderId = '1mqcs93TiDXV5OKU-AwaTf8x5YTYcWiAV';
    const response = await drive.files.list({
      q: `'${folderId}' in parents and mimeType='application/vnd.google-apps.spreadsheet'`,
      fields: 'files(id, name)',
      spaces: 'drive',
    });

    console.log('Fetched sheets:', response.data.files);

    res.json({ sheets: response.data.files });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Function to fetch data from Google Sheets
async function getWorkoutData(
  spreadsheetId: string,
  range: string,
  auth: OAuth2Client
): Promise<WorkoutData[]> {
  try {
    const sheets = google.sheets({
      version: 'v4',
      auth: auth,
    });

    const response = await sheets.spreadsheets.values.get({
      spreadsheetId,
      range,
    });

    const rows = response.data.values;
    if (!rows || rows.length === 0) {
      return [];
    }

    // Assuming first row is headers
    const headers = rows[0];
    const workouts: WorkoutData[] = [];

    // Convert rows to workout objects
    for (let i = 1; i < rows.length; i++) {
      const row = rows[i];
      const workout: any = {};

      headers.forEach((header: string, index: number) => {
        const value = row[index];

        // Convert numeric values
        if (['sets', 'reps', 'weight'].includes(header.toLowerCase())) {
          workout[header.toLowerCase()] = value ? Number(value) : null;
        } else {
          workout[header.toLowerCase()] = value || '';
        }
      });

      workouts.push(workout as WorkoutData);
    }
    console.log('Fetched workout data:', workouts);
    return workouts;
  } catch (error) {
    console.error('Error fetching workout data:', error);
    throw error;
  }
}

// Endpoint to get workout data from a specific sheet
app.get('/api/workouts/:spreadsheetId', async (req, res) => {
  const userId = req.headers['user-id'] as string;
  const userToken = userTokens.get(userId);

  if (!userToken) {
    return res.status(401).json({ error: 'User not authenticated' });
  }

  try {
    const { spreadsheetId } = req.params;
    const range = (req.query.range as string) || 'A1:F100';

    oauth2Client.setCredentials(userToken);
    const workouts = await getWorkoutData(spreadsheetId, range, oauth2Client);
    res.json({ workouts });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
