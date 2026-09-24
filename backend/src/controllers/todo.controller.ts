import { Request, Response } from 'express';
import { todoService } from '../services/todo.service';
import { asyncHandler } from '../utils/asyncHandler';
import { getParam, sendSuccess } from '../utils/http';
import { CreateTodoInput, UpdateTodoInput } from '../types/todo';

export class TodoController {
  list = asyncHandler(async (_req: Request, res: Response) => {
    const todos = await todoService.list();
    sendSuccess(res, todos);
  });

  getById = asyncHandler(async (req: Request, res: Response) => {
    const todo = await todoService.getById(getParam(req, 'id'));
    sendSuccess(res, todo);
  });

  create = asyncHandler(async (req: Request, res: Response) => {
    const todo = await todoService.create(req.body as CreateTodoInput);
    sendSuccess(res, todo, 201, 'Todo created');
  });

  update = asyncHandler(async (req: Request, res: Response) => {
    const todo = await todoService.update(getParam(req, 'id'), req.body as UpdateTodoInput);
    sendSuccess(res, todo, 200, 'Todo updated');
  });

  remove = asyncHandler(async (req: Request, res: Response) => {
    await todoService.remove(getParam(req, 'id'));
    sendSuccess(res, null, 200, 'Todo deleted');
  });
}

export const todoController = new TodoController();
