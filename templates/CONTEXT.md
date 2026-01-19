# CONTEXT.md - Project Context

## Stack

- **Language**: TypeScript, Python
- **Framework**: Node.js, React
- **Database**: PostgreSQL
- **Message Queue**: RabbitMQ
- **Cache**: Redis
- **Deployment**: Kubernetes on AWS

## Links

- **GitHub**: https://github.com/org/project
- **Slack**: #channel
- **Documentation**: https://docs.example.com

## Conventions

- Conventional commits
- TypeScript strict mode
- Prettier formatting
- ESLint configuration
- pytest for Python
- Jest for TypeScript

## Code Style

```typescript
// Example code style
interface User {
  id: string;
  name: string;
  email: string;
}

function createUser(data: User): User {
  return { ...data, id: uuid() };
}
```

## Directory Structure

```
src/
├── components/
├── services/
├── utils/
├── types/
└── index.ts
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| DATABASE_URL | Yes | PostgreSQL connection string |
| REDIS_URL | Yes | Redis connection string |
| API_KEY | No | External API key |

## Testing Requirements

- Unit test coverage > 80%
- Integration tests for all endpoints
- E2E tests for critical user journeys

## Security Standards

- All API endpoints require authentication
- Sensitive data encrypted at rest
- No secrets in code
- Regular dependency updates
