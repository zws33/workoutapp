// server.ts
import express from 'express';
import dotenv from 'dotenv';
import { GoogleSheetsService } from './googleSheets';
import { verifyGoogleToken } from './authenticate';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON requests
app.use(express.json());

// Serve static files from public directory
app.use(express.static('public'));

// Determine environment (default to development)
const isProd = process.env.NODE_ENV === 'production';

// Get the Google Sheet ID from environment variables
const sheetId = process.env.GOOGLE_SHEET_ID;
if (!sheetId) {
  throw new Error('GOOGLE_SHEET_ID environment variable not set');
}

// Create an instance of the Google Sheets service
const sheetsService = new GoogleSheetsService(sheetId);

// Define routes
app.get('/api/sheets', async (req, res) => {
  try {
    const sheetNames = await sheetsService.getSheetNames();
    res.json({ sheetNames });
  } catch (error) {
    console.error('Error getting sheet names:', error);
    res.status(500).json({ error: 'Failed to fetch sheet names' });
  }
});

app.get('/api/sheets/:sheetName', verifyGoogleToken, async (req, res) => {
  const { sheetName } = req.params;
  const range = req.query.range as string;
  try {
    const data = await sheetsService.getSheetData(sheetName, range);
    res.json(data);
  } catch (error) {
    console.error(`Error getting data from sheet ${sheetName}:`, error);
    res
      .status(500)
      .json({ error: `Failed to fetch data from sheet ${sheetName}` });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
