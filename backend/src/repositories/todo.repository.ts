import { randomUUID } from 'crypto';
import { ResultSetHeader } from 'mysql2';
import { getPool, TodoRow } from '../config/database';
import { CreateTodoInput, Todo, UpdateTodoInput } from '../types/todo';
import { NotFoundError } from '../utils/AppError';

const mapRowToTodo = (row: TodoRow): Todo => ({
  id: row.id,
  title: row.title,
  description: row.description,
  status: row.status,
  createdAt: new Date(row.created_at).toISOString(),
  updatedAt: new Date(row.updated_at).toISOString(),
});

export class TodoRepository {
  async findAll(): Promise<Todo[]> {
    const [rows] = await getPool().query<TodoRow[]>(
      'SELECT id, title, description, status, created_at, updated_at FROM todos ORDER BY created_at DESC',
    );
    return rows.map(mapRowToTodo);
  }

  async findById(id: string): Promise<Todo | undefined> {
    const [rows] = await getPool().query<TodoRow[]>(
      'SELECT id, title, description, status, created_at, updated_at FROM todos WHERE id = ?',
      [id],
    );
    const row = rows[0];
    return row ? mapRowToTodo(row) : undefined;
  }

  async create(input: CreateTodoInput): Promise<Todo> {
    const now = new Date();
    const todo: Todo = {
      id: randomUUID(),
      title: input.title,
      description: input.description ?? '',
      status: input.status ?? 'pending',
      createdAt: now.toISOString(),
      updatedAt: now.toISOString(),
    };

    await getPool().execute(
      `INSERT INTO todos (id, title, description, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [todo.id, todo.title, todo.description, todo.status, now, now],
    );

    return todo;
  }

  async update(id: string, input: UpdateTodoInput): Promise<Todo> {
    const existing = await this.findById(id);
    if (!existing) {
      throw new NotFoundError(`Todo ${id} not found`);
    }

    const updated: Todo = {
      ...existing,
      ...input,
      updatedAt: new Date().toISOString(),
    };

    const [result] = await getPool().execute<ResultSetHeader>(
      `UPDATE todos
       SET title = ?, description = ?, status = ?, updated_at = ?
       WHERE id = ?`,
      [updated.title, updated.description, updated.status, new Date(updated.updatedAt), id],
    );

    if (result.affectedRows === 0) {
      throw new NotFoundError(`Todo ${id} not found`);
    }

    return updated;
  }

  async delete(id: string): Promise<void> {
    const [result] = await getPool().execute<ResultSetHeader>(
      'DELETE FROM todos WHERE id = ?',
      [id],
    );

    if (result.affectedRows === 0) {
      throw new NotFoundError(`Todo ${id} not found`);
    }
  }
}

export const todoRepository = new TodoRepository();
