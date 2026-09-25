import type {
  ApiErrorResponse,
  ApiSuccessResponse,
  CreateTodoInput,
  Todo,
  UpdateTodoInput,
} from '../types/todo'
import { getTodosApiBase } from '../config/api'

const API_BASE = getTodosApiBase()

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  })

  const body = (await response.json()) as ApiSuccessResponse<T> | ApiErrorResponse

  if (!response.ok || !body.success) {
    const message =
      !body.success && body.error?.message
        ? body.error.message
        : `Request failed with status ${response.status}`
    throw new Error(message)
  }

  return body.data
}

export const todoApi = {
  list: () => request<Todo[]>(API_BASE),

  getById: (id: string) => request<Todo>(`${API_BASE}/${id}`),

  create: (input: CreateTodoInput) =>
    request<Todo>(API_BASE, {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  update: (id: string, input: UpdateTodoInput) =>
    request<Todo>(`${API_BASE}/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  remove: (id: string) =>
    request<null>(`${API_BASE}/${id}`, {
      method: 'DELETE',
    }),
}
