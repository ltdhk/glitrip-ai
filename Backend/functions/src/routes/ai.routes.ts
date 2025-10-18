/**
 * AI Routes
 */

import { Router } from 'express';
import { AiController } from '../controllers/ai.controller';
import { authenticateUser } from '../middleware/auth.middleware';
import {
  validateRequest,
  generatePlanSchema,
} from '../middleware/validation.middleware';

const router = Router();
const aiController = new AiController();

/**
 * @route   POST /api/v1/ai/generate-plan
 * @desc    Generate AI travel plan
 * @access  Private
 */
router.post(
  '/generate-plan',
  authenticateUser,
  validateRequest(generatePlanSchema),
  aiController.generatePlan
);

/**
 * @route   GET /api/v1/ai/usage
 * @desc    Get user's AI usage info
 * @access  Private
 */
router.get('/usage', authenticateUser, aiController.getUsage);

/**
 * @route   GET /api/v1/ai/history
 * @desc    Get user's AI generation history
 * @access  Private
 */
router.get('/history', authenticateUser, aiController.getHistory);

export default router;
