import { z } from 'zod';

export const todoStatusSchema = z.enum(['pending', 'in_progress', 'completed']);

export const createTodoSchema = z.object({
  title: z.string().trim().min(1).max(200),
  description: z.string().trim().max(2000).optional().default(''),
  status: todoStatusSchema.optional().default('pending'),
});

export const updateTodoSchema = z
  .object({
    title: z.string().trim().min(1).max(200).optional(),
    description: z.string().trim().max(2000).optional(),
    status: todoStatusSchema.optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field is required',
  });

export const todoIdParamsSchema = z.object({
  id: z.string().uuid(),
});
