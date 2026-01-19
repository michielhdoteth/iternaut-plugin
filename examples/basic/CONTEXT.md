# CONTEXT.md - Task Manager API

## Stack

- **Language**: TypeScript
- **Framework**: Node.js + Express
- **Database**: PostgreSQL
- **Auth**: JWT (jsonwebtoken)
- **Testing**: Jest + Supertest
- **Formatting**: Prettier
- **Linting**: ESLint

## Code Style

```typescript
// Use strict TypeScript
// Interface for request bodies
interface CreateTaskRequest {
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
}

// Use async/await for async operations
async function createTask(req: Request, res: Response) {
  const task = await Task.create(req.body);
  res.status(201).json(task);
}
```

## Directory Structure

```
src/
├── config/         # Configuration
├── controllers/    # Route handlers
├── models/         # Database models
├── middleware/     # Express middleware
├── routes/         # Route definitions
├── utils/          # Helper functions
├── types/          # TypeScript types
└── app.ts          # Express app
```

## Environment Variables

```
DATABASE_URL=postgresql://user:pass@localhost:5432/taskmanager
JWT_SECRET=your-jwt-secret
PORT=3000
NODE_ENV=development
```

## Testing Requirements

- Unit tests for utils and models
- Integration tests for API endpoints
- Coverage > 80%
