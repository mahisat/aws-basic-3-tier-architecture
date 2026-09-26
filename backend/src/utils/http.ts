import { Request, Response } from 'express';

export const sendSuccess = <T>(
  res: Response,
  data: T,
  statusCode = 200,
  message?: string,
): Response => {
  return res.status(statusCode).json({
    success: true,
    ...(message ? { message } : {}),
    data,
    date: new Date().toISOString(),
  });
};

export const sendError = (
  res: Response,
  message: string,
  statusCode = 500,
  details?: unknown,
): Response => {
  return res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(details !== undefined ? { details } : {}),
    },
  });
};

export const getParam = (req: Request, key: string): string => {
  const value = req.params[key];
  if (typeof value !== 'string') {
    throw new Error(`Missing route param: ${key}`);
  }
  return value;
};
