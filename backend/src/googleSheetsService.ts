import { google, sheets_v4 } from 'googleapis';

export class GoogleSheetsService {
  private sheets: sheets_v4.Sheets;
  private spreadsheetId: string;
  constructor(spreadsheetId: string) {
    this.sheets = google.sheets('v4');
    this.spreadsheetId = spreadsheetId;
    const credentials = Deno.env.get('GOOGLE_CREDENTIALS');
    const auth = new google.auth.GoogleAuth({
      keyFile: credentials,
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
      const fullRange = range ? `${sheetName}!${range}` : sheetName;
      const response = await this.sheets.spreadsheets.values.get({
        spreadsheetId: this.spreadsheetId,
        range: fullRange,
      });

      const rows = response.data.values;

      if (!rows || rows.length === 0) {
        throw new Error('No data found in the sheet');
      }

      return rows;
  }

  /**
   * Get sheet names from the spreadsheet
   * @returns Array of sheet names
   */
  async getSheetNames() {
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
