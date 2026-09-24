export type TodoStatus = 'pending' | 'in_progress' | 'completed'

export interface Todo {
  id: string
  title: string
  description: string
  status: TodoStatus
  createdAt: string
  updatedAt: string
}

export interface CreateTodoInput {
  title: string
  description?: string
  status?: TodoStatus
}

export interface UpdateTodoInput {
  title?: string
  description?: string
  status?: TodoStatus
}

export interface ApiSuccessResponse<T> {
  success: true
  message?: string
  data: T
}

export interface ApiErrorResponse {
  success: false
  error: {
    message: string
    details?: unknown
  }
}
