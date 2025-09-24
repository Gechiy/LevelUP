# SkillForge: Professional Skill Development Tracker

A decentralized platform built on Stacks blockchain for tracking professional growth and expertise development.

## Overview

SkillForge is a smart contract that enables professionals to track their skill development journey through various activities like learning, mentoring, and earning certifications. The platform uses a point-based system where different activities contribute experience points toward overall expertise level.

## Features

### Core Functionality
- **Developer Registration**: Register as a developer to start tracking progress
- **Activity Tracking**: Record completion of learning courses, mentoring sessions, and certifications
- **Experience System**: Earn experience points based on completed activities
- **Active Expertise Calculation**: Dynamic expertise calculation that considers activity recency
- **Admin Controls**: Contract owner can adjust experience values for different activities

### Activity Types & Default Experience Values
- **Learning**: 10 experience points per course completion
- **Mentoring**: 5 experience points per mentoring session conducted
- **Certification**: 15 experience points per certification earned

## Smart Contract Functions

### Public Functions

#### `register-developer()`
Registers a new developer profile in the system.
- **Returns**: Success response or error if developer already exists
- **Initial Values**: All metrics start at 0

#### `complete-learning()`
Records completion of a learning course.
- **Updates**: Expertise level (+10 exp), courses taken count, last update timestamp
- **Requires**: Registered developer profile

#### `conduct-mentoring()`
Records a completed mentoring session.
- **Updates**: Expertise level (+5 exp), mentoring sessions count, last update timestamp
- **Requires**: Registered developer profile

#### `earn-certification()`
Records earning of a professional certification.
- **Updates**: Expertise level (+15 exp), certifications count, last update timestamp
- **Requires**: Registered developer profile

#### `adjust-activity-value(activity-type, new-exp)` (Admin Only)
Allows the contract owner to modify experience values for activities.
- **Parameters**: 
  - `activity-type`: "learning", "mentoring", or "certification"
  - `new-exp`: New experience value (capped at 1000)
- **Access**: Contract deployer only

### Read-Only Functions

#### `get-developer-progress(developer)`
Retrieves complete progress information for a developer.
- **Returns**: Object containing expertise level, activity counts, and last update
- **Parameters**: Developer's principal address

#### `get-activity-experience(activity-type)`
Gets the current experience value for a specific activity type.
- **Parameters**: Activity type string
- **Returns**: Experience value object

#### `get-active-expertise(developer)`
Calculates current active expertise considering time decay.
- **Parameters**: Developer's principal address
- **Returns**: Adjusted expertise level based on recent activity
- **Note**: Expertise gradually decreases with inactivity

## Data Structures

### Developer Progress
```clarity
{
    expertise-level: uint,      // Total experience points earned
    courses-taken: uint,        // Number of courses completed
    mentoring-sessions: uint,   // Number of mentoring sessions conducted
    last-update: uint,          // Block height of last activity
    certifications: uint        // Number of certifications earned
}
```

### Activity Values
```clarity
{
    activity: string-ascii 24,  // Activity type identifier
    experience: uint            // Experience points awarded
}
```

## Error Codes

- `u100` - Master only: Unauthorized access to admin functions
- `u101` - Developer missing: Developer profile not found
- `u102` - Unauthorized: General authorization error
- `u103` - Developer exists: Attempt to register existing developer
- `u104` - Profile missing: Developer profile required but not found
- `u105` - Invalid skill: Unknown or invalid activity type
- `u106` - Invalid data: General data validation error

## Usage Examples

### For Developers

1. **Register as a developer**:
   ```clarity
   (contract-call? .skillforge register-developer)
   ```

2. **Complete a learning course**:
   ```clarity
   (contract-call? .skillforge complete-learning)
   ```

3. **Record a mentoring session**:
   ```clarity
   (contract-call? .skillforge conduct-mentoring)
   ```

4. **Earn a certification**:
   ```clarity
   (contract-call? .skillforge earn-certification)
   ```

5. **Check your progress**:
   ```clarity
   (contract-call? .skillforge get-developer-progress 'SP1ABC...)
   ```

### For Administrators

1. **Adjust learning experience value**:
   ```clarity
   (contract-call? .skillforge adjust-activity-value "learning" u12)
   ```

## Key Features

### Experience Decay System
The contract implements an "active expertise" calculation that considers how recently a developer has been active. Expertise points gradually lose their impact over time if no new activities are recorded, encouraging continuous learning and engagement.

### Flexible Experience System
Administrators can adjust the experience values for different activities, allowing the platform to evolve and maintain balanced incentives as the community grows.

### Comprehensive Tracking
The system tracks not just overall expertise but also specific metrics for each type of activity, providing detailed insights into a developer's growth pattern.

## Security Features

- **Access Control**: Admin functions are restricted to the contract deployer
- **Input Validation**: All inputs are validated before processing
- **Error Handling**: Comprehensive error codes for different failure scenarios
- **Bounds Checking**: Experience values are capped to prevent overflow

