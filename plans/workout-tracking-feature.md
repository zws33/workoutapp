# Workout Tracking Feature Plan

## **Current State Analysis**
Your app currently:
- Shows workout definitions (exercises with prescribed sets/reps/weight)
- Uses Core Data with `ExerciseEntity`, `WorkoutEntity`, `ScheduleEntity`, `ExerciseGroupEntity`
- Has a clean UI showing exercises in sections (Primary, Secondary, Cardio, Core)
- Displays exercise details like "3 sets · 12 reps · 40 lbs"

## **Proposed Architecture for Workout Tracking**

### **1. Data Model Changes**

#### **Current State:**
- `WorkoutEntity` - Has `id` (String), `day` (String)
- `ExerciseEntity` - Has `id` (String), `name`, `sets`, `reps`, `weight`, `notes`
- `ExerciseGroupEntity` - Has `groupKey` (String)
- `ScheduleEntity` - Has `id` (String)

#### **Required Changes:**

**A. New Entities:**
- **`WorkoutLogEntity`** - Tracks actual workout sessions
  - `id` (String) - UUID for the log entry
  - `workoutId` (String) - References WorkoutEntity.id
  - `date` (Date) - When workout was performed
  - `startTime` (Date) - When workout started
  - `endTime` (Date, optional) - When workout completed
  - `completed` (Bool) - Whether workout was finished
  - `notes` (String, optional) - Overall workout notes

- **`ExerciseLogEntity`** - Tracks performance per exercise
  - `id` (String) - UUID for the log entry
  - `exerciseId` (String) - References ExerciseEntity.id
  - `workoutLogId` (String) - References WorkoutLogEntity.id
  - `actualSets` (Int64) - Sets actually performed
  - `actualReps` (Int64) - Reps actually performed  
  - `actualWeight` (String) - Weight actually used
  - `performanceNotes` (String) - Exercise-specific notes
  - `completed` (Bool) - Whether this exercise was finished

#### **Relationships:**
- `WorkoutLogEntity` → `ExerciseLogEntity` (one-to-many)
- `WorkoutLogEntity` → `WorkoutEntity` (many-to-one, via workoutId)
- `ExerciseLogEntity` → `ExerciseEntity` (many-to-one, via exerciseId)

### **2. UI/UX Flow & Design**

#### **Core UX Philosophy:**
- Keep workout definition as primary interface
- Make logging lightweight and contextual
- Minimize navigation between screens
- Use modals for quick data entry

#### **Interaction Flow:**
```
WorkoutView (workout definition - primary screen)
    ↓
[Log Workout] button (top of screen)
    ↓ (creates log object in memory)
Button changes to [View Log]
    ↓
User swipes on exercise rows → Modal popup for logging
    ↓
[View Log] button → Navigate to dedicated log review screen
```

#### **Key Components:**

**A. WorkoutView Updates:**
- Add "Log Workout" / "View Log" toggle button at top
- Visual indicators on exercise rows showing logged status
- Swipe gesture handling on exercise rows

**B. Exercise Logging Modal:**
- Triggered by swiping on exercise row
- Input fields for actual reps, weight, sets
- Notes field for exercise-specific observations
- Quick save and dismiss

**C. Log Review Screen (WorkoutLogView):**
- Dedicated screen accessed via "View Log" button
- Shows complete logged progress for current workout
- Compare target vs actual performance
- Overall workout completion status

### **3. Key Components to Build**

#### **UI Components:**
- `ExerciseLoggingModal` - Modal popup for logging exercise performance
- `WorkoutLogView` - Dedicated screen for reviewing logged progress
- `LogToggleButton` - "Log Workout" / "View Log" button component
- Updated `ExerciseRow` - Add swipe gesture and visual indicators

#### **Business Logic:**
- `WorkoutLogManager` - Manages in-memory log state and persistence
- Core Data updates for new entities (`WorkoutLogEntity`, `ExerciseLogEntity`)

#### **State Management:**
- In-memory workout log state
- Exercise completion tracking
- Auto-save functionality

### **4. User Experience Flow**

#### **Starting a Log:**
1. User views workout definition in `WorkoutView`
2. Taps "Log Workout" button at top of screen
3. `WorkoutLogEntity` created in memory, button changes to "View Log"
4. Exercise rows gain visual indicators showing "not logged" state

#### **Logging Exercise Performance:**
1. User swipes on any exercise row
2. `ExerciseLoggingModal` appears with input fields:
   - Actual sets performed
   - Actual reps per set
   - Actual weight used
   - Performance notes (form issues, difficulty, etc.)
3. User saves data, modal dismisses
4. Exercise row updates with visual indicator showing "logged" state

#### **Reviewing Progress:**
1. User taps "View Log" button
2. Navigates to `WorkoutLogView` showing:
   - Complete workout progress
   - Target vs actual comparison for each exercise
   - Overall completion percentage
   - Workout duration and notes

#### **Key UX Benefits:**
- **Contextual**: Logging happens in context of workout definition
- **Non-disruptive**: Swipe gesture feels natural, modal keeps user in flow
- **Progressive**: User can log exercises as they complete them
- **Flexible**: Can review progress without losing current context

### **5. Technical Considerations**
- Preserve existing workout definition data (read-only templates)
- New tracking data stored separately (allows progress history)
- Real-time save to prevent data loss
- Clear visual distinction between prescribed vs. actual values
