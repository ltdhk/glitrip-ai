/**
 * GliTrip Backend - Main Entry Point
 *
 * Express应用和Google Cloud Function导出
 */

import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

// 导入路由
import authRoutes from './routes/auth.routes';
import aiRoutes from './routes/ai.routes';
import subscriptionRoutes from './routes/subscription.routes';

// 导入中间件
import { errorHandler, notFoundHandler } from './middleware/error-handler.middleware';

// 导入配置
import { CORS_CONFIG, RATE_LIMIT_CONFIG } from './config/constants';
import { testDatabaseConnection } from './config/supabase.config';

// 加载环境变量
dotenv.config();

/**
 * 创建Express应用
 */
function createApp(): Application {
  const app = express();

  // ==========================================
  // 基础中间件
  // ==========================================

  // CORS
  app.use(cors(CORS_CONFIG));

  // 安全头
  app.use(helmet());

  // JSON解析
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // 速率限制
  const limiter = rateLimit({
    windowMs: RATE_LIMIT_CONFIG.windowMs,
    max: RATE_LIMIT_CONFIG.max,
    message: RATE_LIMIT_CONFIG.message,
    standardHeaders: true,
    legacyHeaders: false,
  });
  app.use('/api/', limiter);

  // ==========================================
  // 路由
  // ==========================================

  // 健康检查
  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'glitrip-backend',
      version: '1.0.0',
    });
  });

  // API路由
  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/ai', aiRoutes);
  app.use('/api/v1/subscriptions', subscriptionRoutes);

  // 根路径
  app.get('/', (_req, res) => {
    res.json({
      message: 'GliTrip Backend API',
      version: '1.0.0',
      endpoints: {
        health: '/health',
        auth: '/api/v1/auth',
        ai: '/api/v1/ai',
        subscriptions: '/api/v1/subscriptions',
      },
      documentation: 'https://github.com/your-repo/glitrip-backend',
    });
  });

  // ==========================================
  // 错误处理
  // ==========================================

  // 404处理
  app.use(notFoundHandler);

  // 全局错误处理
  app.use(errorHandler);

  return app;
}

/**
 * 启动服务器（本地开发）
 */
async function startServer() {
  const app = createApp();
  const PORT = process.env.PORT || 3000;

  // 测试数据库连接
  console.log('Testing database connection...');
  const dbConnected = await testDatabaseConnection();
  if (!dbConnected) {
    console.error('❌ Database connection failed. Please check your Supabase configuration.');
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`
╔═══════════════════════════════════════╗
║   GliTrip Backend API Server          ║
╠═══════════════════════════════════════╣
║   Environment: ${process.env.NODE_ENV || 'development'}
║   Port: ${PORT}
║   URL: http://localhost:${PORT}
║   Health: http://localhost:${PORT}/health
║   API Docs: http://localhost:${PORT}/
╚═══════════════════════════════════════╝
    `);
  });
}

/**
 * Google Cloud Function 导出
 *
 * 用于部署到Google Cloud Functions
 */
export const api = createApp();

/**
 * 本地开发启动
 *
 * 仅在直接运行此文件时启动服务器
 */
if (require.main === module) {
  startServer().catch((error) => {
    console.error('Failed to start server:', error);
    process.exit(1);
  });
}
