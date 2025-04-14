import { google, sheets_v4 } from 'googleapis';
import * as path from 'path';

export interface SheetRow {
  [key: string]: string;
}

export class GoogleSheetsService {
  private sheets: sheets_v4.Sheets;
  private spreadsheetId: string;
  constructor(spreadsheetId: string) {
    this.sheets = google.sheets('v4');
    this.spreadsheetId = spreadsheetId;
    const auth = new google.auth.GoogleAuth({
      keyFile: path.join(__dirname, '../credentials.json'),
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });
    this.sheets = google.sheets({ version: 'v4', auth });
  }

  /**
   * Get all data from a specific sheet
   * @param sheetName The name of the sheet tab to read from
   * @param range The range to read (e.g., 'A1:D10' or just 'A:D')
   * @returns Array of row data
   */
  async getSheetData(sheetName: string, range?: string) {
    try {
      const fullRange = range ? `${sheetName}!${range}` : sheetName;

      const response = await this.sheets.spreadsheets.values.get({
        spreadsheetId: this.spreadsheetId,
        range: fullRange,
      });

      const rows = response.data.values;

      if (!rows || rows.length === 0) {
        return [];
      }

      // Assuming the first row contains headers
      const headers = rows[0];
      const data = rows.slice(1).map((row) => {
        const rowData: SheetRow = {};
        headers.forEach((header, index) => {
          rowData[header.toString()] = row[index] || '';
        });
        return rowData;
      });

      const grouped = data.reduce((acc: { [key: string]: SheetRow[] }, row) => {
        const key = row[headers[0]]; // Assuming the first column is the key
        if (!acc[key]) {
          acc[key] = [];
        }
        acc[key].push(row);
        return acc;
      }, {});

      return grouped;
    } catch (error) {
      console.error('Error fetching Google Sheet data:', error);
      throw error;
    }
  }

  /**
   * Get sheet names from the spreadsheet
   * @returns Array of sheet names
   */
  async getSheetNames(): Promise<string[]> {
    try {
      const response = await this.sheets.spreadsheets.get({
        spreadsheetId: this.spreadsheetId,
      });

      return response.data.sheets!.map((sheet) => sheet.properties!.title!);
    } catch (error) {
      console.error('Error getting sheet names:', error);
      throw error;
    }
  }
}
