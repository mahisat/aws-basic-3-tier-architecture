import { createApp } from './app';
import { closeDatabase, initDatabase } from './config/database';
import { env } from './config/env';

const start = async () => {
  await initDatabase();

  const app = createApp();

  const server = app.listen(env.PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${env.PORT} [${env.NODE_ENV}]`);
  });

  const shutdown = async (signal: string) => {
    console.log(`${signal} received, shutting down`);
    server.close(async () => {
      await closeDatabase();
      process.exit(0);
    });
  };

  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
};

start().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
