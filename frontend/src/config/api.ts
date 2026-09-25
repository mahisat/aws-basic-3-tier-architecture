/**
 * Base URL for the todos API (no trailing slash on the /api segment).
 *
 * - Unset or "/api" → requests go to /api/todos on the same host (nginx proxies to backend).
 * - Absolute URL (e.g. http://10.0.2.5:5000/api) is only for clients inside the VPC;
 *   public browsers cannot reach a private IP.
 */
export function getTodosApiBase(): string {
  const configured = import.meta.env.VITE_API_BASE_URL?.trim()

  if (!configured) {
    return '/api/todos'
  }

  const root = configured.replace(/\/$/, '')

  if (root.startsWith('/')) {
    return `${root}/todos`
  }

  return `${root}/todos`
}
