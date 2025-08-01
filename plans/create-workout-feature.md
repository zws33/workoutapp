# Create Workout Feature - Technical Specification

## Overview

This document outlines the implementation plan for adding a Create Workout feature to the iOS workout tracking app. Currently, users can only view existing workouts fetched from the backend. This feature will enable users to create custom workouts locally with background synchronization.

## Current Architecture Analysis

### Existing Foundation
- **Core Data entities**: ScheduleEntity → WorkoutEntity → ExerciseGroupEntity → ExerciseEntity
- **Repository pattern**: WorkoutRepository handles data fetching/syncing with backend
- **MVVM architecture**: ViewModels handle business logic, Views handle UI
- **Exercise categories**: Primary, Secondary, Cardio, Core with different display priorities
- **Authentication**: Firebase Auth integration for backend API access

### Current Data Flow
1. Backend syncs workout data from Google Sheets via cron jobs
2. iOS app fetches data from backend API using WorkoutRepository
3. Data persists locally with Core Data for offline access
4. UI displays workouts through WorkoutView with day-based filtering

## Feature Requirements

### Functional Requirements
- **Create custom workouts** with name, day, and exercises
- **Add exercises** to different categories (Primary, Secondary, Cardio, Core)
- **Configure exercise details**: sets, reps, weight, notes
- **Save workouts locally** with immediate availability
- **Background sync** custom workouts to backend when network available
- **Edit and delete** custom workouts
- **Visual distinction** between custom and synced workouts

### Non-Functional Requirements
- **Offline-first**: Works without network connectivity
- **Data consistency**: Local changes sync reliably to backend
- **User experience**: Intuitive creation flow following iOS design patterns
- **Performance**: Responsive UI during workout creation and editing

## Technical Architecture

### 1. UI/UX Components

#### Primary Views
- **`CreateWorkoutView`** - Main creation interface with navigation and save functionality
- **`ExerciseFormView`** - Add/edit individual exercises with input validation
- **`ExercisePicker`** - Browse and select from exercise library or add custom
- **`WorkoutPreviewView`** - Review workout before saving with edit capabilities

#### Supporting Components
- **`CategoryPicker`** - Select Primary/Secondary/Cardio/Core with visual indicators
- **`ExerciseRowEditor`** - Inline editing for sets/reps/weight with number pads
- **`NotesInputView`** - Multi-line text input for exercise notes
- **`SaveWorkoutSheet`** - Modal for workout name, day selection, and final save

#### Navigation Integration
- Add "+" button to existing WorkoutView toolbar
- Present CreateWorkoutView as sheet or navigation push
- Maintain day selection context from parent view
- Breadcrumb navigation for deep editing flows

### 2. Data Flow Architecture

#### Local-First Approach
1. **Create locally** → Save to Core Data immediately for instant availability
2. **Background sync** → Push to backend when network available and user authenticated
3. **Conflict resolution** → Backend becomes source of truth, merge strategies for conflicts

#### Repository Extensions
```swift
protocol WorkoutRepository {
    // Existing methods...
    
    // New methods for custom workouts
    func createWorkout(_ workout: Workout, in schedule: Schedule) async throws -> Workout
    func updateWorkout(_ workout: Workout) async throws -> Workout
    func deleteWorkout(_ workout: Workout) async throws
    func syncPendingWorkouts() async throws
    func getCustomWorkouts() async throws -> [Workout]
}
```

### 3. Core Data Integration

#### Schema Extensions
Add new attributes to existing entities:

**WorkoutEntity additions:**
- `isCustom: Bool` - Distinguish user-created vs backend workouts
- `syncStatus: String` - Track sync state (pending/synced/error/conflict)
- `createdDate: Date` - Creation timestamp for sorting
- `modifiedDate: Date` - Last modification timestamp

**Sync Status Values:**
- `pending` - Created locally, not yet synced
- `syncing` - Currently uploading to backend
- `synced` - Successfully synchronized
- `error` - Sync failed, retry needed
- `conflict` - Server version differs, resolution needed

#### Data Validation Rules
- Workout must have name and at least one exercise
- Exercise names must be unique within each category
- Numeric fields (sets, reps) must be positive integers
- Weight field accepts flexible string format (e.g., "135 lbs", "60 kg")

### 4. Backend Integration

#### API Endpoints (Future Implementation)
```
POST /api/workouts          - Create custom workout
PUT /api/workouts/:id       - Update custom workout  
DELETE /api/workouts/:id    - Delete custom workout
GET /api/workouts/custom    - Fetch user's custom workouts
```

#### Sync Strategy
- **Upload queue**: Local changes queued for background sync
- **Conflict resolution**: Last-write-wins with user notification
- **Error handling**: Retry logic with exponential backoff
- **Offline support**: Full functionality without network

## Implementation Phases

### Phase 1: Core Infrastructure (Week 1-2)
**Goal**: Basic workout creation with local storage

**Tasks:**
- [ ] Extend Core Data model with custom workout fields
- [ ] Create Core Data migration for schema changes
- [ ] Add repository methods for local workout CRUD operations
- [ ] Create basic `CreateWorkoutView` with navigation setup
- [ ] Implement `WorkoutFormViewModel` for state management

**Deliverables:**
- Updated Core Data model with migration
- Basic workout creation flow
- Local storage of custom workouts

### Phase 2: Exercise Management (Week 3-4)
**Goal**: Complete exercise creation and editing functionality

**Tasks:**
- [ ] Build `ExerciseFormView` for adding/editing exercises
- [ ] Implement category selection UI (Primary/Secondary/Cardio/Core)
- [ ] Add input fields for sets, reps, weight, and notes
- [ ] Create exercise validation and error handling
- [ ] Add drag-and-drop reordering within categories

**Deliverables:**
- Full exercise creation workflow
- Input validation and error states
- Exercise reordering functionality

### Phase 3: Enhanced UX (Week 5-6)
**Goal**: Polish user experience and add convenience features

**Tasks:**
- [ ] Exercise library/picker for common exercises
- [ ] Workout templates for quick creation
- [ ] Auto-save drafts to prevent data loss
- [ ] Visual indicators for custom vs synced workouts
- [ ] Accessibility improvements and VoiceOver support

**Deliverables:**
- Exercise library with search
- Template system
- Improved accessibility

### Phase 4: Backend Integration (Week 7-8)
**Goal**: Sync custom workouts with backend

**Tasks:**
- [ ] Design and implement backend API endpoints
- [ ] Add background sync with queue management
- [ ] Implement conflict resolution strategies
- [ ] Add network state monitoring
- [ ] Create sync status indicators in UI

**Deliverables:**
- Backend API for custom workouts
- Background synchronization
- Offline/online state management

## Key Technical Considerations

### Data Validation
- **Required fields**: Workout name, at least one exercise per workout
- **Numeric validation**: Sets and reps must be positive integers
- **String validation**: Exercise names must be non-empty and unique within category
- **Weight format**: Flexible string input with common format suggestions

### User Experience
- **Auto-save**: Continuously save draft state to prevent data loss
- **Visual feedback**: Clear loading states during save/sync operations  
- **Error recovery**: Graceful handling of network failures and validation errors
- **Consistency**: Match existing app patterns for navigation and styling

### Performance Considerations
- **Core Data performance**: Use background contexts for heavy operations
- **Memory management**: Efficient handling of large exercise lists
- **Network efficiency**: Batch sync operations and implement delta sync
- **UI responsiveness**: Non-blocking operations with proper async/await usage

### Security and Privacy
- **Authentication**: Ensure all API calls include valid Firebase tokens
- **Data ownership**: Users can only access/modify their own custom workouts
- **Local storage**: Secure Core Data storage following iOS best practices
- **Sync integrity**: Verify data consistency between local and remote storage

## Success Metrics

### User Experience Metrics
- Time to create first workout < 3 minutes
- User retention after creating custom workouts
- Error rate during workout creation < 1%
- Sync success rate > 99%

### Technical Metrics
- App launch time impact < 100ms
- Core Data migration success rate 100%
- Background sync completion rate > 95%
- Memory usage increase < 10MB during creation

## Risks and Mitigation

### Technical Risks
- **Core Data migration failures**: Comprehensive testing with various data states
- **Sync conflicts**: Clear conflict resolution UI and fallback strategies
- **Performance degradation**: Profile memory and CPU usage throughout development

### User Experience Risks
- **Complex creation flow**: User testing and iteration on UI/UX
- **Data loss**: Robust auto-save and error recovery mechanisms
- **Inconsistent behavior**: Maintain patterns established in existing codebase

## Future Enhancements

### Planned Features
- **Workout sharing**: Share custom workouts with other users
- **Exercise tracking**: Log completed sets and track progress
- **Workout analytics**: Statistics and progress visualization
- **Social features**: Community workout templates and ratings

### Technical Improvements
- **Real-time sync**: WebSocket-based live updates
- **Advanced search**: Full-text search across exercises and workouts
- **Backup/restore**: iCloud backup for custom workouts
- **Import/export**: CSV or JSON workout data exchange

---

**Document Version**: 1.0  
**Last Updated**: August 1, 2025  
**Author**: Technical Planning Session  
**Status**: Planning Complete, Ready for Implementation