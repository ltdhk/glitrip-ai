import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_migration.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'glitrip.db');

    if (kDebugMode) {
      print('数据库路径: $path');
    }

    return await openDatabase(
      path,
      version: 12, // 增加版本号以触发升级，为todos表添加category字段
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // 创建目的地表
      await txn.execute('''
        CREATE TABLE destinations (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          country TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL CHECK (status IN ('visited', 'planned', 'wishlist')),
          budget_level TEXT NOT NULL CHECK (budget_level IN ('high', 'medium', 'low')),
          estimated_cost REAL,
          recommended_days INTEGER NOT NULL DEFAULT 1,
          best_time_description TEXT,
          start_date TEXT,
          end_date TEXT,
          tags TEXT,
          travel_notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 创建旅行伴侣表
      await txn.execute('''
        CREATE TABLE travel_buddies (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          availability TEXT,
          budget_level TEXT CHECK (budget_level IN ('high', 'medium', 'low')),
          confirmed_to_travel INTEGER NOT NULL DEFAULT 0,
          adventure_preference INTEGER NOT NULL DEFAULT 0,
          relaxation_preference INTEGER NOT NULL DEFAULT 0,
          culture_preference INTEGER NOT NULL DEFAULT 0,
          foodie_preference INTEGER NOT NULL DEFAULT 0,
          nature_preference INTEGER NOT NULL DEFAULT 0,
          urban_preference INTEGER NOT NULL DEFAULT 0,
          dream_destinations TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 创建目的地-旅行伴侣关联表
      await txn.execute('''
        CREATE TABLE destination_buddies (
          destination_id TEXT NOT NULL,
          buddy_id TEXT NOT NULL,
          PRIMARY KEY (destination_id, buddy_id),
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE,
          FOREIGN KEY (buddy_id) REFERENCES travel_buddies (id) ON DELETE CASCADE
        )
      ''');

      // 创建文档表
      await txn.execute('''
        CREATE TABLE documents (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('passport', 'id_card', 'visa', 'insurance', 'ticket', 'hotel', 'car_rental', 'other')),
          has_expiry INTEGER NOT NULL DEFAULT 0,
          expiry_date TEXT,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 创建文档图片表
      await txn.execute('''
        CREATE TABLE document_images (
          id TEXT PRIMARY KEY,
          document_id TEXT NOT NULL,
          image_path TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
        )
      ''');

      // 创建文档-目的地关联表
      await txn.execute('''
        CREATE TABLE document_destinations (
          document_id TEXT NOT NULL,
          destination_id TEXT NOT NULL,
          PRIMARY KEY (document_id, destination_id),
          FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 创建物品表
      await txn.execute('''
        CREATE TABLE packing_items (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT NOT NULL CHECK (category IN ('clothing', 'electronics', 'cosmetics', 'health', 'accessories', 'books', 'entertainment', 'other')),
          quantity INTEGER NOT NULL DEFAULT 1,
          is_essential INTEGER NOT NULL DEFAULT 0,
          is_packed INTEGER NOT NULL DEFAULT 0,
          destination_id TEXT,
          language TEXT DEFAULT 'zh',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 创建用户配置表
      await txn.execute('''
        CREATE TABLE user_profile (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL DEFAULT '旅行家',
          signature TEXT NOT NULL DEFAULT '新的冒险等待着！',
          avatar_path TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 创建费用/预算表
      await txn.execute('''
        CREATE TABLE expenses (
          id TEXT PRIMARY KEY,
          destination_id TEXT NOT NULL,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL CHECK (category IN ('accommodation', 'transport', 'food', 'activities', 'shopping', 'insurance', 'visa', 'other')),
          date TEXT NOT NULL,
          is_paid INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 创建行程天数表
      await txn.execute('''
        CREATE TABLE itinerary_days (
          id TEXT PRIMARY KEY,
          destination_id TEXT NOT NULL,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          day_number INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 创建行程活动表
      await txn.execute('''
        CREATE TABLE itinerary_activities (
          id TEXT PRIMARY KEY,
          day_id TEXT NOT NULL,
          time TEXT NOT NULL,
          title TEXT NOT NULL,
          location TEXT NOT NULL,
          cost REAL,
          notes TEXT,
          is_booked INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (day_id) REFERENCES itinerary_days (id) ON DELETE CASCADE
        )
      ''');

      // 创建回忆表
      await txn.execute('''
        CREATE TABLE memories (
          id TEXT PRIMARY KEY,
          destination_id TEXT NOT NULL,
          title TEXT NOT NULL,
          location TEXT NOT NULL,
          date TEXT NOT NULL,
          rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
          description TEXT,
          photos TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 创建待办事项表（AI生成）
      await txn.execute('''
        CREATE TABLE todos (
          id TEXT PRIMARY KEY,
          destination_id TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT CHECK (category IN ('passport', 'idCard', 'visa', 'insurance', 'ticket', 'hotel', 'carRental', 'other')) DEFAULT 'other',
          priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
          is_completed INTEGER NOT NULL DEFAULT 0,
          deadline TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
        )
      ''');

      // 插入默认用户配置
      await txn.insert('user_profile', {
        'id': 'default_user',
        'name': '旅行家',
        'signature': '新的冒险等待着！',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 初始化旅行物品模板（destination_id 为 null）
      final now = DateTime.now().toIso8601String();
      final templateItems = [
        // 服装类 (clothing)
        {
          'name': 'T恤',
          'category': 'clothing',
          'quantity': 3,
          'is_essential': 1
        },
        {
          'name': '长袖衬衫',
          'category': 'clothing',
          'quantity': 2,
          'is_essential': 1
        },
        {
          'name': '长裤',
          'category': 'clothing',
          'quantity': 2,
          'is_essential': 1
        },
        {
          'name': '短裤',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '内衣',
          'category': 'clothing',
          'quantity': 5,
          'is_essential': 1
        },
        {
          'name': '袜子',
          'category': 'clothing',
          'quantity': 5,
          'is_essential': 1
        },
        {
          'name': '运动鞋',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '拖鞋',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '外套',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '睡衣',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '泳衣',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '帽子',
          'category': 'clothing',
          'quantity': 1,
          'is_essential': 0
        },

        // 电子产品类 (electronics)
        {
          'name': '手机',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '手机充电器',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '充电宝',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '充电线',
          'category': 'electronics',
          'quantity': 2,
          'is_essential': 1
        },
        {
          'name': '转换插头',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '耳机',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '相机',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '平板电脑',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '笔记本电脑',
          'category': 'electronics',
          'quantity': 1,
          'is_essential': 0
        },

        // 洗护用品类 (cosmetics)
        {
          'name': '牙刷',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '牙膏',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '洗面奶',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '洗发水',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '护发素',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '沐浴露',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '护肤品',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '防晒霜',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },
        {
          'name': '化妆品',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '剃须刀',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '毛巾',
          'category': 'cosmetics',
          'quantity': 2,
          'is_essential': 1
        },
        {
          'name': '梳子',
          'category': 'cosmetics',
          'quantity': 1,
          'is_essential': 1
        },

        // 医疗健康类 (health)
        {
          'name': '常用药品',
          'category': 'health',
          'quantity': 1,
          'is_essential': 1
        },
        {'name': '感冒药', 'category': 'health', 'quantity': 1, 'is_essential': 1},
        {'name': '止痛药', 'category': 'health', 'quantity': 1, 'is_essential': 1},
        {'name': '创可贴', 'category': 'health', 'quantity': 5, 'is_essential': 1},
        {'name': '消毒液', 'category': 'health', 'quantity': 1, 'is_essential': 1},
        {'name': '肠胃药', 'category': 'health', 'quantity': 1, 'is_essential': 1},
        {'name': '晕车药', 'category': 'health', 'quantity': 1, 'is_essential': 0},
        {'name': '口罩', 'category': 'health', 'quantity': 10, 'is_essential': 1},
        {'name': '体温计', 'category': 'health', 'quantity': 1, 'is_essential': 0},

        // 配饰类 (accessories)
        {
          'name': '太阳镜',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '手表',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '围巾',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '手套',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '腰包',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '雨伞',
          'category': 'accessories',
          'quantity': 1,
          'is_essential': 1
        },

        // 书籍类 (books)
        {'name': '旅行指南', 'category': 'books', 'quantity': 1, 'is_essential': 0},
        {'name': '笔记本', 'category': 'books', 'quantity': 1, 'is_essential': 0},
        {'name': '笔', 'category': 'books', 'quantity': 2, 'is_essential': 0},

        // 娱乐类 (entertainment)
        {
          'name': '扑克牌',
          'category': 'entertainment',
          'quantity': 1,
          'is_essential': 0
        },
        {
          'name': '便携游戏机',
          'category': 'entertainment',
          'quantity': 1,
          'is_essential': 0
        },

        // 其他类 (other)
        {'name': '护照', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '身份证', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '钱包', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '现金', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '银行卡', 'category': 'other', 'quantity': 2, 'is_essential': 1},
        {'name': '行李箱', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '背包', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '保温杯', 'category': 'other', 'quantity': 1, 'is_essential': 0},
        {'name': '塑料袋', 'category': 'other', 'quantity': 5, 'is_essential': 1},
        {'name': '纸巾', 'category': 'other', 'quantity': 2, 'is_essential': 1},
        {'name': '湿巾', 'category': 'other', 'quantity': 1, 'is_essential': 1},
        {'name': '指甲刀', 'category': 'other', 'quantity': 1, 'is_essential': 0},
        {'name': '缝纫包', 'category': 'other', 'quantity': 1, 'is_essential': 0},
        {'name': '洗衣袋', 'category': 'other', 'quantity': 2, 'is_essential': 1},
      ];

      int itemIndex = 0;
      for (var item in templateItems) {
        await txn.insert('packing_items', {
          'id': 'template_item_${itemIndex++}',
          'name': item['name'],
          'category': item['category'],
          'quantity': item['quantity'],
          'is_essential': item['is_essential'],
          'is_packed': 0,
          'destination_id': null, // 模板物品
          'language': 'zh', // 中文模板
          'created_at': now,
          'updated_at': now,
        });
      }
    });

    // 添加英文模板物品
    await _addEnglishTemplateItems(db);

    // 运行数据库修复
    await DatabaseMigration.fixPackingItemsTable(db);

    if (kDebugMode) {
      print('数据库表创建完成，已添加中英文模板');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (kDebugMode) {
      print('数据库从版本 $oldVersion 升级到 $newVersion');
    }

    if (oldVersion < 2) {
      // 添加文档图片表
      await db.execute('''
        CREATE TABLE document_images (
          id TEXT PRIMARY KEY,
          document_id TEXT NOT NULL,
          image_path TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
        )
      ''');

      if (kDebugMode) {
        print('已添加 document_images 表');
      }
    }

    if (oldVersion < 3) {
      // 确保旅伴表存在且结构正确
      await db.execute('''
        CREATE TABLE IF NOT EXISTS travel_buddies (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          availability TEXT,
          budget_level TEXT CHECK (budget_level IN ('high', 'medium', 'low')),
          confirmed_to_travel INTEGER NOT NULL DEFAULT 0,
          adventure_preference INTEGER NOT NULL DEFAULT 0,
          relaxation_preference INTEGER NOT NULL DEFAULT 0,
          culture_preference INTEGER NOT NULL DEFAULT 0,
          foodie_preference INTEGER NOT NULL DEFAULT 0,
          nature_preference INTEGER NOT NULL DEFAULT 0,
          urban_preference INTEGER NOT NULL DEFAULT 0,
          dream_destinations TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      if (kDebugMode) {
        print('已确保 travel_buddies 表结构正确');
      }
    }

    if (oldVersion < 4) {
      // 为打包物品表添加 destination_id 字段
      await db.execute('''
        ALTER TABLE packing_items ADD COLUMN destination_id TEXT
      ''');

      // 添加外键约束（注意：SQLite 的 ALTER TABLE 不支持直接添加外键约束）
      // 外键约束将在新建表时生效

      if (kDebugMode) {
        print('已为 packing_items 表添加 destination_id 字段');
      }
    }

    if (oldVersion < 5) {
      // 确保 destination_id 字段存在（如果之前没有正确添加）
      try {
        await db.execute('''
          ALTER TABLE packing_items ADD COLUMN destination_id TEXT
        ''');
        if (kDebugMode) {
          print('已确保 packing_items 表有 destination_id 字段');
        }
      } catch (e) {
        // 如果字段已存在，忽略错误
        if (kDebugMode) {
          print('destination_id 字段可能已存在: $e');
        }
      }
    }

    // 版本6：已移除示例数据初始化

    if (oldVersion < 7) {
      // 清空所有示例数据，初始化模板物品
      if (kDebugMode) {
        print('开始清理示例数据并初始化模板物品...');
      }

      try {
        // 清空目的地相关数据（会级联删除关联的物品和文档）
        await db.delete('destinations');
        // 清空文档数据
        await db.delete('documents');
        // 清空所有物品（包括旧的模板和目的地物品）
        await db.delete('packing_items');
        // 清空旅伴数据
        await db.delete('travel_buddies');

        // 初始化旅行物品模板
        final now = DateTime.now().toIso8601String();
        final templateItems = [
          // 服装类 (clothing)
          {
            'name': 'T恤',
            'category': 'clothing',
            'quantity': 3,
            'is_essential': 1
          },
          {
            'name': '长袖衬衫',
            'category': 'clothing',
            'quantity': 2,
            'is_essential': 1
          },
          {
            'name': '长裤',
            'category': 'clothing',
            'quantity': 2,
            'is_essential': 1
          },
          {
            'name': '短裤',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '内衣',
            'category': 'clothing',
            'quantity': 5,
            'is_essential': 1
          },
          {
            'name': '袜子',
            'category': 'clothing',
            'quantity': 5,
            'is_essential': 1
          },
          {
            'name': '运动鞋',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '拖鞋',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '外套',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '睡衣',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '泳衣',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '帽子',
            'category': 'clothing',
            'quantity': 1,
            'is_essential': 0
          },

          // 电子产品类 (electronics)
          {
            'name': '手机',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '手机充电器',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '充电宝',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '充电线',
            'category': 'electronics',
            'quantity': 2,
            'is_essential': 1
          },
          {
            'name': '转换插头',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '耳机',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '相机',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '平板电脑',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '笔记本电脑',
            'category': 'electronics',
            'quantity': 1,
            'is_essential': 0
          },

          // 洗护用品类 (cosmetics)
          {
            'name': '牙刷',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '牙膏',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '洗面奶',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '洗发水',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '护发素',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '沐浴露',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '护肤品',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '防晒霜',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '化妆品',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '剃须刀',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '毛巾',
            'category': 'cosmetics',
            'quantity': 2,
            'is_essential': 1
          },
          {
            'name': '梳子',
            'category': 'cosmetics',
            'quantity': 1,
            'is_essential': 1
          },

          // 医疗健康类 (health)
          {
            'name': '常用药品',
            'category': 'health',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '感冒药',
            'category': 'health',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '止痛药',
            'category': 'health',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '创可贴',
            'category': 'health',
            'quantity': 5,
            'is_essential': 1
          },
          {
            'name': '消毒液',
            'category': 'health',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '肠胃药',
            'category': 'health',
            'quantity': 1,
            'is_essential': 1
          },
          {
            'name': '晕车药',
            'category': 'health',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '口罩',
            'category': 'health',
            'quantity': 10,
            'is_essential': 1
          },
          {
            'name': '体温计',
            'category': 'health',
            'quantity': 1,
            'is_essential': 0
          },

          // 配饰类 (accessories)
          {
            'name': '太阳镜',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '手表',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '围巾',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '手套',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '腰包',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '雨伞',
            'category': 'accessories',
            'quantity': 1,
            'is_essential': 1
          },

          // 书籍类 (books)
          {
            'name': '旅行指南',
            'category': 'books',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '笔记本',
            'category': 'books',
            'quantity': 1,
            'is_essential': 0
          },
          {'name': '笔', 'category': 'books', 'quantity': 2, 'is_essential': 0},

          // 娱乐类 (entertainment)
          {
            'name': '扑克牌',
            'category': 'entertainment',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '便携游戏机',
            'category': 'entertainment',
            'quantity': 1,
            'is_essential': 0
          },

          // 其他类 (other)
          {'name': '护照', 'category': 'other', 'quantity': 1, 'is_essential': 1},
          {
            'name': '身份证',
            'category': 'other',
            'quantity': 1,
            'is_essential': 1
          },
          {'name': '钱包', 'category': 'other', 'quantity': 1, 'is_essential': 1},
          {'name': '现金', 'category': 'other', 'quantity': 1, 'is_essential': 1},
          {
            'name': '银行卡',
            'category': 'other',
            'quantity': 2,
            'is_essential': 1
          },
          {
            'name': '行李箱',
            'category': 'other',
            'quantity': 1,
            'is_essential': 1
          },
          {'name': '背包', 'category': 'other', 'quantity': 1, 'is_essential': 1},
          {
            'name': '保温杯',
            'category': 'other',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '塑料袋',
            'category': 'other',
            'quantity': 5,
            'is_essential': 1
          },
          {'name': '纸巾', 'category': 'other', 'quantity': 2, 'is_essential': 1},
          {'name': '湿巾', 'category': 'other', 'quantity': 1, 'is_essential': 1},
          {
            'name': '指甲刀',
            'category': 'other',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '缝纫包',
            'category': 'other',
            'quantity': 1,
            'is_essential': 0
          },
          {
            'name': '洗衣袋',
            'category': 'other',
            'quantity': 2,
            'is_essential': 1
          },
        ];

        int itemIndex = 0;
        for (var item in templateItems) {
          await db.insert('packing_items', {
            'id': 'template_item_${itemIndex++}',
            'name': item['name'],
            'category': item['category'],
            'quantity': item['quantity'],
            'is_essential': item['is_essential'],
            'is_packed': 0,
            'destination_id': null, // 模板物品
            'language': 'zh', // 中文模板
            'created_at': now,
            'updated_at': now,
          });
        }

        if (kDebugMode) {
          print('已完成数据清理和模板初始化，共${templateItems.length}个模板物品');
        }
      } catch (e) {
        if (kDebugMode) {
          print('清理数据和初始化模板时出错: $e');
        }
      }
    }

    // 运行数据库修复以确保表结构正确
    await DatabaseMigration.fixPackingItemsTable(db);

    if (oldVersion < 8) {
      // 添加费用/预算表
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id TEXT PRIMARY KEY,
            destination_id TEXT NOT NULL,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL CHECK (category IN ('accommodation', 'transport', 'food', 'activities', 'shopping', 'insurance', 'visa', 'other')),
            date TEXT NOT NULL,
            is_paid INTEGER NOT NULL DEFAULT 0,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
          )
        ''');

        if (kDebugMode) {
          print('已添加 expenses 表');
        }
      } catch (e) {
        if (kDebugMode) {
          print('添加 expenses 表时出错: $e');
        }
      }
    }

    if (oldVersion < 9) {
      // 添加行程和回忆相关表
      try {
        // 创建行程天数表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS itinerary_days (
            id TEXT PRIMARY KEY,
            destination_id TEXT NOT NULL,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            day_number INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
          )
        ''');

        // 创建行程活动表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS itinerary_activities (
            id TEXT PRIMARY KEY,
            day_id TEXT NOT NULL,
            time TEXT NOT NULL,
            title TEXT NOT NULL,
            location TEXT NOT NULL,
            cost REAL,
            notes TEXT,
            is_booked INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (day_id) REFERENCES itinerary_days (id) ON DELETE CASCADE
          )
        ''');

        // 创建回忆表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS memories (
            id TEXT PRIMARY KEY,
            destination_id TEXT NOT NULL,
            title TEXT NOT NULL,
            location TEXT NOT NULL,
            date TEXT NOT NULL,
            rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
            description TEXT,
            photos TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
          )
        ''');

        if (kDebugMode) {
          print('已添加 itinerary_days、itinerary_activities 和 memories 表');
        }
      } catch (e) {
        if (kDebugMode) {
          print('添加行程和回忆表时出错: $e');
        }
      }
    }

    if (oldVersion < 10) {
      // 为打包物品表添加 language 字段
      try {
        await db.execute('''
          ALTER TABLE packing_items ADD COLUMN language TEXT DEFAULT 'zh'
        ''');

        // 更新现有模板物品的语言为中文
        await db.execute('''
          UPDATE packing_items SET language = 'zh' WHERE destination_id IS NULL
        ''');

        // 添加英文模板物品
        await _addEnglishTemplateItems(db);

        if (kDebugMode) {
          print('已为 packing_items 表添加 language 字段并添加英文模板');
        }
      } catch (e) {
        if (kDebugMode) {
          print('添加 language 字段时出错: $e');
        }
      }
    }

    if (oldVersion < 11) {
      // 添加todos表
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS todos (
            id TEXT PRIMARY KEY,
            destination_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
            is_completed INTEGER NOT NULL DEFAULT 0,
            deadline TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
          )
        ''');

        if (kDebugMode) {
          print('已添加 todos 表');
        }
      } catch (e) {
        if (kDebugMode) {
          print('添加 todos 表时出错: $e');
        }
      }
    }

    if (oldVersion < 12) {
      // 为todos表添加category字段
      try {
        await db.execute('''
          ALTER TABLE todos ADD COLUMN category TEXT CHECK (category IN ('passport', 'idCard', 'visa', 'insurance', 'ticket', 'hotel', 'carRental', 'other')) DEFAULT 'other'
        ''');

        if (kDebugMode) {
          print('已为 todos 表添加 category 字段');
        }
      } catch (e) {
        if (kDebugMode) {
          print('添加 category 字段时出错: $e');
        }
      }
    }
  }

  // 添加英文模板物品
  Future<void> _addEnglishTemplateItems(Database db) async {
    final now = DateTime.now().toIso8601String();
    final templateItems = [
      // Clothing
      {
        'name': 'T-shirts',
        'category': 'clothing',
        'quantity': 3,
        'is_essential': 1
      },
      {
        'name': 'Long-sleeve shirts',
        'category': 'clothing',
        'quantity': 2,
        'is_essential': 1
      },
      {
        'name': 'Pants',
        'category': 'clothing',
        'quantity': 2,
        'is_essential': 1
      },
      {
        'name': 'Shorts',
        'category': 'clothing',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Underwear',
        'category': 'clothing',
        'quantity': 5,
        'is_essential': 1
      },
      {
        'name': 'Socks',
        'category': 'clothing',
        'quantity': 5,
        'is_essential': 1
      },
      {
        'name': 'Jacket',
        'category': 'clothing',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Comfortable shoes',
        'category': 'clothing',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Slippers',
        'category': 'clothing',
        'quantity': 1,
        'is_essential': 0
      },
      {'name': 'Hat', 'category': 'clothing', 'quantity': 1, 'is_essential': 0},
      {
        'name': 'Sunglasses',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Swimsuit',
        'category': 'clothing',
        'quantity': 1,
        'is_essential': 0
      },

      // Electronics
      {
        'name': 'Phone charger',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Power bank',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Camera',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Headphones',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Travel adapter',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Laptop',
        'category': 'electronics',
        'quantity': 1,
        'is_essential': 0
      },

      // Cosmetics
      {
        'name': 'Toothbrush',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Toothpaste',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Shampoo',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Body wash',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Facial cleanser',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Skincare products',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Sunscreen',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Razor',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Comb',
        'category': 'cosmetics',
        'quantity': 1,
        'is_essential': 0
      },

      // Health
      {
        'name': 'First aid kit',
        'category': 'health',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Cold medicine',
        'category': 'health',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Band-aids',
        'category': 'health',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Vitamins',
        'category': 'health',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Insect repellent',
        'category': 'health',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Prescription medication',
        'category': 'health',
        'quantity': 1,
        'is_essential': 1
      },

      // Accessories
      {
        'name': 'Watch',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Wallet',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Backpack',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Umbrella',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Water bottle',
        'category': 'accessories',
        'quantity': 1,
        'is_essential': 1
      },

      // Books
      {
        'name': 'Guidebook',
        'category': 'books',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Reading book',
        'category': 'books',
        'quantity': 1,
        'is_essential': 0
      },

      // Entertainment
      {
        'name': 'Tablet',
        'category': 'entertainment',
        'quantity': 1,
        'is_essential': 0
      },
      {
        'name': 'Playing cards',
        'category': 'entertainment',
        'quantity': 1,
        'is_essential': 0
      },

      // Other
      {
        'name': 'Passport',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'ID card',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Travel insurance',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Cash/credit cards',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Tissue paper',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Wet wipes',
        'category': 'other',
        'quantity': 1,
        'is_essential': 1
      },
      {
        'name': 'Laundry bag',
        'category': 'other',
        'quantity': 2,
        'is_essential': 1
      },
    ];

    int itemIndex = 0;
    for (var item in templateItems) {
      await db.insert('packing_items', {
        'id': 'template_item_en_${itemIndex++}',
        'name': item['name'],
        'category': item['category'],
        'quantity': item['quantity'],
        'is_essential': item['is_essential'],
        'is_packed': 0,
        'destination_id': null,
        'language': 'en',
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 通用查询方法
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // 通用插入方法
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  // 通用更新方法
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // 通用删除方法
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // 执行原始SQL
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // 执行原始SQL（无返回值）
  Future<void> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawQuery(sql, arguments);
  }

  // 批量执行
  Future<List<dynamic>> batch(Function(Batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }

  // 事务执行
  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // 删除数据库文件
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'glitrip.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
