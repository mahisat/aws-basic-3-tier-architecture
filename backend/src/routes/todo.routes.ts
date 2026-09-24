import { Router } from 'express';
import { todoController } from '../controllers/todo.controller';
import { validate } from '../middleware/validate';
import {
  createTodoSchema,
  todoIdParamsSchema,
  updateTodoSchema,
} from '../validators/todo.validator';

const router = Router();

router.get('/', todoController.list);
router.get('/:id', validate(todoIdParamsSchema, 'params'), todoController.getById);
router.post('/', validate(createTodoSchema, 'body'), todoController.create);
router.patch(
  '/:id',
  validate(todoIdParamsSchema, 'params'),
  validate(updateTodoSchema, 'body'),
  todoController.update,
);
router.delete('/:id', validate(todoIdParamsSchema, 'params'), todoController.remove);

export default router;
