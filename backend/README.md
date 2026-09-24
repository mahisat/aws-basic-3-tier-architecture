# Todo API

Express.js + TypeScript API with a layered structure: routes → controllers → services → repositories.

## Layout

```
src/
  server.ts                 HTTP server + shutdown
  app.ts                    Express app, middleware, route mount
  config/env.ts             Validated environment
  routes/                   HTTP route maps
  controllers/              Request / response only
  services/                 Business rules
  repositories/             Data access (in-memory for now)
  validators/               Zod request schemas
  middleware/               Errors, 404, validation
  types/                    Shared TypeScript types
  utils/                    Errors, async wrapper, HTTP helpers
```

Swap the repository for Postgres, DynamoDB, or another store without changing controllers or routes.

## Setup

```bash
npm install
cp .env.example .env
npm run dev
```

- `npm run dev` — watch mode
- `npm run build` — compile to `dist/`
- `npm start` — run compiled output

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/todos` | List todos |
| GET | `/api/todos/:id` | Get one todo |
| POST | `/api/todos` | Create todo |
| PATCH | `/api/todos/:id` | Update todo |
| DELETE | `/api/todos/:id` | Delete todo |

### Create

```json
{
  "title": "Write API docs",
  "description": "Optional",
  "status": "pending"
}
```

`status` is one of `pending`, `in_progress`, `completed`.
