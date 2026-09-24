import { Request, Response } from 'express';
import { sendError } from '../utils/http';

export const notFoundHandler = (req: Request, res: Response): void => {
  sendError(res, `Cannot ${req.method} ${req.originalUrl}`, 404);
};
