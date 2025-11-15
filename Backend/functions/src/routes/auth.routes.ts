/**
 * Authentication Routes
 */

import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateUser } from '../middleware/auth.middleware';
import {
  validateRequest,
  registerSchema,
  loginSchema,
} from '../middleware/validation.middleware';

const router = Router();
const authController = new AuthController();

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  validateRequest(registerSchema),
  authController.register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  validateRequest(loginSchema),
  authController.login
);

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user info
 * @access  Private
 */
router.get('/me', authenticateUser, authController.me);

/**
 * @route   POST /api/v1/auth/refresh
 * @desc    Refresh JWT token
 * @access  Private
 */
router.post('/refresh', authenticateUser, authController.refreshToken);

/**
 * @route   DELETE /api/v1/auth/delete
 * @desc    Delete current user account
 * @access  Private
 */
router.delete('/delete', authenticateUser, authController.deleteAccount);

export default router;
