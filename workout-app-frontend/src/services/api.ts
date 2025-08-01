import type { Schedule } from '../types/Types.ts';

const API_BASE_URL =
  process.env.NODE_ENV === 'production'
    ? 'https://your-backend-url.com' // Replace with actual production URL
    : 'http://localhost:3000';

interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  count?: number;
}

interface ApiError {
  success: false;
  error: string;
  details?: Array<{
    field: string;
    message: string;
  }>;
}

class ApiService {
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`;

    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    // Add auth token if available (you'll need to implement auth)
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers = {
        ...config.headers,
        Authorization: `Bearer ${token}`,
      };
    }

    try {
      const response = await fetch(url, config);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.error || `HTTP ${response.status}: ${response.statusText}`
        );
      }

      return data;
    } catch (error) {
      console.error(`API request failed for ${endpoint}:`, error);
      throw error;
    }
  }

  // Convert frontend schedule format to backend format
  private transformScheduleForBackend(schedule: Schedule): any {
    return {
      name: schedule.name,
      workouts: schedule.workouts.map((workout) => ({
        day: `Day ${workout.name}`, // Convert number to string format expected by backend
        exercises: workout.exercises,
      })),
    };
  }

  // Convert backend schedule format to frontend format
  private transformScheduleFromBackend(backendSchedule: any): Schedule {
    return {
      id: backendSchedule.id,
      name: backendSchedule.name,
      workouts: backendSchedule.workouts.map((workout: any, index: number) => ({
        id: workout.id,
        day: index + 1, // Convert back to number format
        exercises: workout.exercises,
      })),
    };
  }

  async getSchedules(): Promise<Schedule[]> {
    const response = await this.request<ApiResponse<Schedule[]>>(
      '/api/schedules'
    );
    if (response.success && response.data) {
      return response.data.map((schedule) =>
        this.transformScheduleFromBackend(schedule)
      );
    }
    throw new Error(response.error || 'Failed to fetch schedules');
  }

  async getScheduleByName(name: string): Promise<Schedule> {
    const encodedName = encodeURIComponent(name);
    const response = await this.request<Schedule>(
      `/api/schedules/${encodedName}`
    );
    return this.transformScheduleFromBackend(response);
  }

  async createSchedule(schedule: Schedule): Promise<Schedule> {
    const backendFormat = this.transformScheduleForBackend(schedule);

    const response = await this.request<ApiResponse<Schedule>>(
      '/api/schedules',
      {
        method: 'POST',
        body: JSON.stringify(backendFormat),
      }
    );

    if (response.success && response.data) {
      return this.transformScheduleFromBackend(response.data);
    }
    throw new Error(response.error || 'Failed to create schedule');
  }

  async updateSchedule(name: string, schedule: Schedule): Promise<Schedule> {
    const encodedName = encodeURIComponent(name);
    const backendFormat = this.transformScheduleForBackend(schedule);

    const response = await this.request<ApiResponse<Schedule>>(
      `/api/schedules/${encodedName}`,
      {
        method: 'PUT',
        body: JSON.stringify(backendFormat),
      }
    );

    if (response.success && response.data) {
      return this.transformScheduleFromBackend(response.data);
    }
    throw new Error(response.error || 'Failed to update schedule');
  }

  async deleteSchedule(name: string): Promise<void> {
    const encodedName = encodeURIComponent(name);
    const response = await this.request<ApiResponse<void>>(
      `/api/schedules/${encodedName}`,
      {
        method: 'DELETE',
      }
    );

    if (!response.success) {
      throw new Error(response.error || 'Failed to delete schedule');
    }
  }
}

export const apiService = new ApiService();
export type { ApiError };
