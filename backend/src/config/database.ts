import mysql, { Pool, RowDataPacket } from 'mysql2/promise';
import { env } from './env';

const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS todos (
  id CHAR(36) PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('pending', 'in_progress', 'completed') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
`;

let pool: Pool | null = null;

export const getPool = (): Pool => {
  if (!pool) {
    throw new Error('Database pool is not initialized');
  }
  return pool;
};

export const initDatabase = async (): Promise<void> => {
  pool = mysql.createPool({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
  });

  await pool.query(SCHEMA_SQL);
};

export const closeDatabase = async (): Promise<void> => {
  if (pool) {
    await pool.end();
    pool = null;
  }
};

export type TodoRow = RowDataPacket & {
  id: string;
  title: string;
  description: string;
  status: 'pending' | 'in_progress' | 'completed';
  created_at: Date;
  updated_at: Date;
};
