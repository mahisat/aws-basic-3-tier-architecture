import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { env } from '../config/env';
import { AppError } from '../utils/AppError';
import { sendError } from '../utils/http';

export const errorHandler = (
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  if (err instanceof AppError) {
    sendError(res, err.message, err.statusCode, err.details);
    return;
  }

  if (err instanceof ZodError) {
    sendError(res, 'Invalid request', 400, err.flatten().fieldErrors);
    return;
  }

  const message = err instanceof Error ? err.message : 'Internal server error';
  const details = env.NODE_ENV === 'development' ? message : undefined;

  console.error(err);
  sendError(res, 'Internal server error', 500, details);
};
