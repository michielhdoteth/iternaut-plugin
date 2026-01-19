# Task Manager API

## Overview

Build a simple REST API for task management with authentication.

## Goals

1. User registration and login with JWT
2. CRUD operations for tasks
3. Task filtering and search
4. Unit test coverage > 80%

## User Stories

1. As a user, I can register with email/password
2. As a user, I can login and receive JWT token
3. As a authenticated user, I can create tasks
4. As a authenticated user, I can list my tasks
5. As a authenticated user, I can update tasks
6. As a authenticated user, I can delete tasks
7. As a authenticated user, I can search tasks by title

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register new user |
| POST | /auth/login | Login and get JWT |
| GET | /tasks | List tasks (with filters) |
| POST | /tasks | Create task |
| GET | /tasks/:id | Get single task |
| PUT | /tasks/:id | Update task |
| DELETE | /tasks/:id | Delete task |

## Data Model

### User
- id: UUID
- email: string (unique)
- password_hash: string
- created_at: timestamp

### Task
- id: UUID
- user_id: UUID (FK)
- title: string
- description: text
- status: enum (pending, in_progress, done)
- priority: enum (low, medium, high)
- due_date: timestamp
- created_at: timestamp
- updated_at: timestamp

## Constraints

- Use Node.js + Express
- Use PostgreSQL database
- Use JWT for authentication
- Write unit tests with Jest
- Follow conventional commits
- Use TypeScript strict mode

## Success Criteria

- All API endpoints working
- 80%+ test coverage
- No security vulnerabilities
- API documentation generated
