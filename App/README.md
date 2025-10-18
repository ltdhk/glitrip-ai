# 轻松旅行 (GliTrip)

一款功能完整的旅行规划应用，使用Flutter开发，支持iOS和Android平台。

## 功能特性

### 🏝️ 目的地管理 (Destinations)
- **搜索与筛选**: 按关键字搜索目的地，按状态（已去过、计划中、愿望清单）筛选
- **完整信息管理**: 
  - 基础信息：目的地名称、国家、描述
  - 旅行详情：状态、预算级别、预算费用、建议天数
  - 最佳时间：时间描述、开始/结束日期
  - 标签和游记描述
- **卡片式展示**: 美观的渐变卡片显示，根据状态使用不同颜色
- **详情页面**: 多标签页展示总览、预算、行程、物品、回忆

### 📄 文档管理 (Documents)  
- **多类型支持**: 护照、身份证、签证、保险、机票、酒店预订、租车等
- **过期提醒**: 自动检测即将过期的文档，提供醒目提示
- **分类展示**: 按文档类型分组显示，便于管理
- **详细信息**: 文档名称、类型、过期日期、备注等

### 🎒 物品打包 (Packing)
- **分类管理**: 按衣服、电子产品、化妆品、药品等分类
- **进度追踪**: 圆形图表显示整体打包进度
- **必需品标记**: 标记重要物品，避免遗漏
- **数量管理**: 支持物品数量设置
- **打包状态**: 一键切换已打包/未打包状态

### 👤 个人资料 (Profile)
- **用户信息**: 头像、姓名、个性签名
- **旅行统计**: 目的地总数、已去过、计划中、愿望清单统计
- **快捷操作**: 快速添加目的地、旅伴、物品

## 技术架构

### 🏗️ 架构模式
- **Clean Architecture**: 清晰的分层架构，易于维护和测试
- **Feature-First**: 按功能模块组织代码结构
- **SOLID原则**: 遵循面向对象设计原则

### 🔧 技术栈
- **Flutter 3.13+**: 跨平台UI框架
- **Dart 3.1+**: 编程语言
- **Riverpod 2.x**: 状态管理
- **SQLite**: 本地数据存储
- **sqflite**: SQLite数据库操作
- **fl_chart**: 图表组件

### 📁 项目结构
```
lib/
├── core/                           # 核心功能
│   ├── database/                   # 数据库相关
│   │   └── database_helper.dart    # 数据库助手类
│   └── providers/                  # 全局Provider
│       └── providers.dart          # 依赖注入配置
├── features/                       # 功能模块
│   ├── destinations/               # 目的地功能
│   │   ├── data/                   # 数据层
│   │   │   ├── datasources/        # 数据源
│   │   │   ├── models/             # 数据模型
│   │   │   └── repositories/       # 仓库实现
│   │   ├── domain/                 # 领域层
│   │   │   ├── entities/           # 实体类
│   │   │   └── repositories/       # 仓库接口
│   │   └── presentation/           # 表现层
│   │       ├── pages/              # 页面
│   │       ├── providers/          # 状态管理
│   │       └── widgets/            # 组件
│   ├── documents/                  # 文档管理
│   ├── packing/                    # 物品打包
│   └── profile/                    # 个人资料
└── main.dart                       # 应用入口
```

## 数据库设计

### 📊 表结构

#### destinations (目的地表)
- `id`: 主键
- `name`: 目的地名称
- `country`: 国家
- `description`: 描述
- `status`: 状态 (visited/planned/wishlist)
- `budget_level`: 预算级别 (high/medium/low)
- `estimated_cost`: 预估费用
- `recommended_days`: 建议天数
- `best_time_description`: 最佳时间描述
- `start_date/end_date`: 开始/结束日期
- `tags`: 标签 (JSON)
- `travel_notes`: 旅行笔记

#### documents (文档表)
- `id`: 主键
- `name`: 文档名称
- `type`: 文档类型
- `has_expiry`: 是否有过期日期
- `expiry_date`: 过期日期
- `description`: 描述

#### packing_items (物品表)
- `id`: 主键
- `name`: 物品名称
- `category`: 类别
- `quantity`: 数量
- `is_essential`: 是否必需
- `is_packed`: 是否已打包

#### user_profile (用户资料表)
- `id`: 主键
- `name`: 用户名
- `signature`: 个性签名
- `avatar_path`: 头像路径

## 安装运行

### 📋 环境要求
- Flutter 3.13.0+
- Dart 3.1.0+
- iOS 11.0+ / Android API 21+

### 🚀 快速开始

1. **克隆项目**
```bash
git clone <repository-url>
cd glitrip/app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

### 🔨 构建发布版本

**Android APK**
```bash
flutter build apk --release
```

**iOS IPA** 
```bash
flutter build ios --release
```

## 主要特性展示

### 🎨 UI设计
- **现代化设计**: Material Design 3风格
- **渐变色彩**: 根据不同状态使用不同渐变色
- **流畅动画**: 页面切换和交互动画
- **响应式布局**: 适配不同屏幕尺寸

### 📱 用户体验
- **直观导航**: 底部标签导航，清晰的页面结构
- **搜索功能**: 实时搜索，快速找到目标内容
- **状态管理**: 实时数据同步，流畅的用户交互
- **错误处理**: 友好的错误提示和重试机制

### 🔒 数据安全
- **本地存储**: 所有数据存储在本地SQLite数据库
- **数据验证**: 完整的输入验证和数据校验
- **事务支持**: 数据库操作支持事务，保证数据一致性

## 开发说明

### 🧪 测试
```bash
flutter test
```

### 📝 代码生成
```bash
flutter packages pub run build_runner build
```

### 🐛 调试
- 使用Flutter Inspector进行UI调试
- 使用Riverpod Inspector查看状态变化
- 数据库调试可使用SQLite浏览器工具

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交Issue和Pull Request来帮助改进这个项目！

---

**轻松旅行 - 让旅行规划变得简单！** ✈️🌍
