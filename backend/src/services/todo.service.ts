import { CreateTodoInput, Todo, UpdateTodoInput } from '../types/todo';
import { todoRepository } from '../repositories/todo.repository';
import { NotFoundError } from '../utils/AppError';

export class TodoService {
  async list(): Promise<Todo[]> {
    return todoRepository.findAll();
  }

  async getById(id: string): Promise<Todo> {
    const todo = await todoRepository.findById(id);
    if (!todo) {
      throw new NotFoundError(`Todo ${id} not found`);
    }
    return todo;
  }

  async create(input: CreateTodoInput): Promise<Todo> {
    return todoRepository.create(input);
  }

  async update(id: string, input: UpdateTodoInput): Promise<Todo> {
    return todoRepository.update(id, input);
  }

  async remove(id: string): Promise<void> {
    await todoRepository.delete(id);
  }
}

export const todoService = new TodoService();
