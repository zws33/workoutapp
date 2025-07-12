# Schedule CRUD API Implementation Plan

## Overview

This document outlines the plan for implementing full CRUD (Create, Read, Update, Delete) functionality for workout schedules in the backend API. Currently, the API only supports reading schedules and creating them via Google Sheets sync.

## Current State Analysis

### Existing CRUD Operations
-  **READ**: `GET /api/schedules` and `GET /api/workouts/:week` 
-  **CREATE**: Only via Google Sheets sync (not direct API)
- L **UPDATE**: Not implemented
- L **DELETE**: Not implemented

### Current Architecture
- **Database**: Google Firestore with `'workouts'` collection
- **Authentication**: Firebase Admin SDK with Bearer tokens
- **Data Models**: TypeScript interfaces with deterministic SHA1 ID generation
- **Patterns**: Repository pattern with layered architecture

## Proposed API Design

Following existing patterns and response formats:

```typescript
// Existing (enhanced)
GET    /api/schedules              # List all schedules
GET    /api/schedules/:name        # Get specific schedule

// New CRUD operations  
POST   /api/schedules              # Create new schedule
PUT    /api/schedules/:name        # Update existing schedule
DELETE /api/schedules/:name        # Delete schedule
```

### Request/Response Examples

#### Create Schedule
```http
POST /api/schedules
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Week 5",
  "workouts": [
    {
      "day": "Monday",
      "exercises": {
        "primary": [
          {
            "name": "Bench Press",
            "sets": 3,
            "reps": 8,
            "weight": "185 lbs"
          }
        ]
      }
    }
  ]
}
```

#### Update Schedule
```http
PUT /api/schedules/Week%205
Authorization: Bearer <token>
Content-Type: application/json

{
  "workouts": [
    // Updated workout data
  ]
}
```

#### Delete Schedule
```http
DELETE /api/schedules/Week%205
Authorization: Bearer <token>
```

## Implementation Plan

### 1. Database Layer Updates (`workoutDb.ts`)

Extend the `WorkoutDb` interface with new methods:

```typescript
interface WorkoutDb {
  // Existing methods
  getSchedules(): Promise<Schedule[]>
  getScheduleByName(name: string): Promise<Schedule | undefined>
  saveSchedule(schedule: Schedule): Promise<void>
  
  // New methods
  updateSchedule(name: string, schedule: Schedule): Promise<void>
  deleteSchedule(name: string): Promise<void>
  scheduleExists(name: string): Promise<boolean>
}
```

**Implementation details:**
- `updateSchedule`: Replace existing document in Firestore
- `deleteSchedule`: Remove document from Firestore collection
- `scheduleExists`: Check if document exists before operations

### 2. Repository Layer Updates (`workoutRepository.ts`)

Add new methods to `WorkoutRepository` class:

```typescript
class WorkoutRepository {
  // New CRUD methods
  async createSchedule(scheduleData: CreateScheduleRequest): Promise<Schedule>
  async updateSchedule(name: string, updates: UpdateScheduleRequest): Promise<Schedule>
  async deleteSchedule(name: string): Promise<void>
  async validateScheduleData(data: any): Promise<ValidationResult>
}
```

**Business logic considerations:**
- Validate input data structure
- Generate deterministic IDs using existing SHA1 hashing
- Handle conflicts with Google Sheets sync
- Maintain data integrity

### 3. API Routes Implementation (`server.ts`)

#### Enhanced existing routes:
```typescript
app.get('/api/schedules/:name', authenticateUser, async (req, res) => {
  // Improved error handling for single schedule retrieval
  // URL decode schedule name
  // Return 404 if not found
})
```

#### New CRUD routes:
```typescript
app.post('/api/schedules', authenticateUser, async (req, res) => {
  // Validate request body
  // Check if schedule name already exists
  // Create new schedule
  // Return created schedule
})

app.put('/api/schedules/:name', authenticateUser, async (req, res) => {
  // Validate request body
  // Check if schedule exists
  // Update schedule
  // Return updated schedule
})

app.delete('/api/schedules/:name', authenticateUser, async (req, res) => {
  // Check if schedule exists
  // Delete schedule
  // Return success confirmation
})
```

## Data Validation Requirements

### Schedule Validation
- **Required fields**: `name`, `workouts` (array)
- **Name constraints**: 
  - Non-empty string
  - Reasonable length (1-100 characters)
  - Unique across all schedules
- **Workouts validation**:
  - Must be array with at least one workout
  - Each workout must have valid `day` and `exercises`

### Workout Validation
- **Day field**: Must be valid day name or date format
- **Exercises**: Must follow existing `Partial<Record<Group, Exercise[]>>` structure
- **Exercise validation**: Follow existing `Exercise` interface requirements

### Exercise Validation
- **Required**: `name`, `sets`
- **Optional**: `reps`, `weight`, `notes`
- **Data types**: Validate according to existing interface

## Error Handling Strategy

### HTTP Status Codes
- **200**: Successful operation
- **201**: Schedule created successfully
- **400**: Invalid request data
- **401**: Unauthorized (invalid/missing token)
- **404**: Schedule not found
- **409**: Schedule name already exists
- **500**: Internal server error

### Error Response Format
```json
{
  "success": false,
  "error": "Schedule with name 'Week 5' already exists",
  "code": "SCHEDULE_EXISTS"
}
```

### Validation Errors
```json
{
  "success": false,
  "error": "Validation failed",
  "details": [
    {
      "field": "name",
      "message": "Workout name is required"
    },
    {
      "field": "workouts",
      "message": "At least one workout is required"
    }
  ]
}
```

## Integration Considerations

### Google Sheets Sync Conflicts
- **Strategy**: API-created schedules take precedence over synced data
- **Identification**: Add metadata to distinguish API vs. sync origins
- **Conflict resolution**: Implement merge strategies or user notifications

### Authentication & Authorization
- **Current**: Firebase Admin SDK with Bearer tokens
- **Future**: Consider role-based permissions (read-only vs. full CRUD)
- **Audit trail**: Log all CRUD operations with user information

### Data Consistency
- **ID generation**: Maintain deterministic SHA1 hashing for deduplication
- **Relationships**: Ensure workout and exercise IDs remain consistent
- **Backup**: Consider backup strategies before destructive operations

## Testing Strategy

### Unit Tests
- **Models**: Test factory functions with new CRUD scenarios
- **Repository**: Test all new CRUD methods with mock data
- **Validation**: Test input validation with various edge cases
- **Database**: Test Firestore operations with integration tests

### Integration Tests
- **API endpoints**: Test full request/response cycles
- **Authentication**: Test protected routes
- **Error handling**: Test various error scenarios
- **Data flow**: Test end-to-end CRUD workflows

### Test Data
- **Valid schedules**: Various schedule configurations
- **Invalid inputs**: Malformed data, missing fields, invalid types
- **Edge cases**: Empty workouts, duplicate names, special characters

## Performance Considerations

### Database Operations
- **Indexing**: Consider Firestore indexes for schedule queries
- **Batch operations**: Implement batch updates for multiple schedules
- **Caching**: Consider caching frequently accessed schedules

### API Performance
- **Validation**: Implement efficient validation without blocking
- **Response size**: Paginate large schedule lists if needed
- **Rate limiting**: Consider implementing rate limiting for CRUD operations

## Future Enhancements

### Version 1.1
- **Batch operations**: Create/update/delete multiple schedules
- **Search functionality**: Search schedules by name, exercises, etc.
- **Schedule templates**: Create reusable schedule templates
- **Import/export**: JSON import/export functionality

### Version 1.2
- **Versioning**: Track schedule versions and changes
- **Sharing**: Share schedules between users
- **Categories**: Organize schedules by categories/tags
- **Analytics**: Track schedule usage and performance

## Implementation Timeline

### Phase 1: Core CRUD (Week 1)
- [ ] Database layer updates
- [ ] Repository layer implementation
- [ ] Basic API routes
- [ ] Input validation

### Phase 2: Error Handling & Testing (Week 2)
- [ ] Comprehensive error handling
- [ ] Unit and integration tests
- [ ] Documentation updates
- [ ] Code review and refinement

### Phase 3: Integration & Polish (Week 3)
- [ ] Google Sheets sync integration
- [ ] Performance optimization
- [ ] Security review
- [ ] Production deployment

## Success Criteria

- [ ] All CRUD operations work correctly
- [ ] Comprehensive test coverage (>90%)
- [ ] Proper error handling and validation
- [ ] Integration with existing Google Sheets sync
- [ ] Performance meets current API standards
- [ ] Security audit passes
- [ ] Documentation complete and accurate

## Risks & Mitigation

### Technical Risks
- **Data corruption**: Implement validation and backup strategies
- **Sync conflicts**: Design clear conflict resolution patterns
- **Performance degradation**: Monitor and optimize database queries

### Business Risks
- **Breaking changes**: Maintain backward compatibility
- **User confusion**: Clear documentation and error messages
- **Data loss**: Implement soft deletes and audit trails

## Conclusion

This implementation plan provides a comprehensive approach to adding full CRUD functionality for workout schedules while maintaining consistency with existing architectural patterns and ensuring robust error handling and data validation.