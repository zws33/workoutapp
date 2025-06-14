# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a multi-platform workout tracking application consisting of three main components:

1. **iOS Native App** (`/workoutapp/`) - SwiftUI-based mobile app with Core Data persistence
2. **React Web Frontend** (`/workout-app-frontend/`) - TypeScript/React web interface  
3. **Node.js Backend API** (`/backend/`) - TypeScript server with Google Sheets integration

## Development Commands

### Backend API (`/backend/`)
- `npm run dev` - Start development server with hot reload (tsx watch)
- `npm run build` - Compile TypeScript to JavaScript
- `npm run test` - Run Jest tests (test files: `src/**/*.test.ts`)
- `npm start` - Start production server
- `./deploy.sh` - Deploy to Google Cloud Run

### Frontend (`/workout-app-frontend/`)
- `npm run dev` - Start Vite development server with hot reload
- `npm run build` - Build for production (TypeScript compilation + Vite build)
- `npm run lint` - Run ESLint code linting
- `npm run preview` - Preview production build locally
- `./deploy.sh` - Deploy to Google Cloud Run

### iOS App (`/workoutapp/`)
- Build and run through Xcode
- Tests run via XCTest framework
- Core Data models managed through Xcode's data model editor

## Core Data Architecture (iOS)

The iOS app uses Core Data with these entities:
- **ScheduleEntity**: Workout schedules containing multiple workouts
- **WorkoutEntity**: Individual workout sessions with day and exercise groups
- **ExerciseGroupEntity**: Groups of exercises identified by groupKey
- **ExerciseEntity**: Individual exercises with sets, reps, weight, and notes

## Key Technologies

### Backend
- **Runtime**: Node.js with Express.js and TypeScript
- **Authentication**: Firebase Admin SDK
- **External APIs**: Google Sheets API for data source
- **Testing**: Jest with ts-jest
- **Scheduling**: node-cron for periodic data sync

### Frontend
- **Framework**: React 19.1.0 with TypeScript
- **Build Tool**: Vite 6.3.5
- **Styling**: Bootstrap 5.3.6
- **Development**: Hot reload via Vite

### iOS
- **Language**: Swift with SwiftUI
- **Authentication**: Firebase Auth + Google Sign-In SDK
- **Persistence**: Core Data with custom entities
- **Architecture**: MVVM with repository pattern

## Deployment

Both backend and frontend are containerized and deployed to Google Cloud Run:
- **Platform**: Google Cloud Platform (Project ID: workout-app-450914)
- **Region**: us-east1
- **Architecture**: linux/amd64 containers
- **Access**: Public (allow-unauthenticated)

## Authentication Flow

The system uses Firebase Authentication with Google OAuth:
1. iOS app: Firebase Auth + Google Sign-In SDK
2. Backend: Firebase Admin SDK for token verification
3. Frontend: Integrates with backend authentication

## Data Flow

1. **Source**: Google Sheets contains workout data
2. **Backend**: Syncs data from Google Sheets via cron jobs
3. **iOS**: Fetches data from backend API and persists locally with Core Data
4. **Frontend**: Fetches data directly from backend API

## Testing

- **Backend**: Jest with TypeScript support, test files in `src/**/*.test.ts`
- **iOS**: XCTest framework for unit and UI tests
- **Frontend**: No explicit test framework configured (uses Vite defaults)