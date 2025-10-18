/**
 * Subscription Routes
 */

import { Router } from 'express';
import { SubscriptionController } from '../controllers/subscription.controller';
import { authenticateUser } from '../middleware/auth.middleware';
import {
  validateRequest,
  upgradeSchema,
} from '../middleware/validation.middleware';

const router = Router();
const subscriptionController = new SubscriptionController();

/**
 * @route   GET /api/v1/subscriptions/current
 * @desc    Get current subscription status
 * @access  Private
 */
router.get(
  '/current',
  authenticateUser,
  subscriptionController.getCurrentSubscription
);

/**
 * @route   POST /api/v1/subscriptions/upgrade
 * @desc    Upgrade to VIP
 * @access  Private
 */
router.post(
  '/upgrade',
  authenticateUser,
  validateRequest(upgradeSchema),
  subscriptionController.upgrade
);

/**
 * @route   POST /api/v1/subscriptions/webhook
 * @desc    Payment webhook callback
 * @access  Public (但需要验证签名)
 */
router.post('/webhook', subscriptionController.webhook);

/**
 * @route   POST /api/v1/subscriptions/cancel
 * @desc    Cancel VIP subscription
 * @access  Private
 */
router.post(
  '/cancel',
  authenticateUser,
  subscriptionController.cancel
);

export default router;
