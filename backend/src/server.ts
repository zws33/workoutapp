import express from 'express';
import dotenv from 'dotenv';
import { GoogleSheetsService } from './googleSheets';
import { verifyGoogleToken } from './authenticate';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use(express.static('public'));

const isProd = process.env.NODE_ENV === 'production';

const sheetId = process.env.GOOGLE_SHEET_ID;
if (!sheetId) {
  throw new Error('GOOGLE_SHEET_ID environment variable not set');
}

const sheetsService = new GoogleSheetsService(sheetId);

app.get('/api/sheets', async (req, res) => {
  try {
    const sheetNames = await sheetsService.getSheetNames();
    res.json(sheetNames);
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

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
