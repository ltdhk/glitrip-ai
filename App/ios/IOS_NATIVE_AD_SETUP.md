# iOS 原生广告设置指南

## 概述
已为iOS平台创建了原生广告实现。需要手动将新创建的文件添加到Xcode项目中。

## 创建的文件
1. `NativeAdFactory.swift` - 原生广告工厂类
2. `NativeAdView.xib` - 原生广告UI布局文件
3. 已更新 `AppDelegate.swift` - 添加了原生广告工厂注册

## 手动步骤（必须完成）

### 1. 打开Xcode项目
```bash
open ios/Runner.xcworkspace
```

### 2. 将Swift文件添加到项目
1. 在Xcode左侧项目导航器中，右键点击 `Runner` 文件夹
2. 选择 `Add Files to "Runner"...`
3. 选择以下两个文件：
   - `ios/Runner/NativeAdFactory.swift`
   - `ios/Runner/NativeAdView.xib`
4. 确保勾选以下选项：
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: Runner

### 3. 配置 Bridging Header（如果提示）
如果Xcode提示创建 Objective-C bridging header，点击"Create Bridging Header"

### 4. 验证配置
确认 `Info.plist` 中已包含 GADApplicationIdentifier：
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```
✅ 已配置

## 代码实现说明

### NativeAdFactory.swift
- 实现了 `GADNativeAdFactory` 协议
- 加载 `NativeAdView.xib` 布局
- 绑定广告数据到UI组件

### NativeAdView.xib
- 定义了原生广告的UI布局
- 包含以下元素：
  - 广告标识 (Ad Badge)
  - 标题 (Headline)
  - 描述 (Body)
  - 图标 (Icon)
  - 媒体视图 (Media View) - 150x150dp
  - 评分 (Star Rating)
  - 操作按钮 (Call to Action)
  - 广告商信息 (Advertiser)

### AppDelegate.swift
- 注册原生广告工厂 ID: "listTile"
- 在应用启动时注册
- 在应用终止时取消注册

## 测试
1. 清理并重新构建项目
2. 运行应用
3. 导航到"文档"页面
4. 添加至少2个文档（原生广告会在第二个文档分组后显示）
5. 广告应该显示在文档列表中

## 测试广告ID
当前使用的是Google AdMob测试广告ID：
- iOS Native Ad: `ca-app-pub-3940256099942544/3986624511`

**正式发布前需要替换为正式的广告ID！**

## 故障排查

### 问题：广告不显示
- 检查网络连接
- 查看Xcode控制台的广告加载日志
- 确认 Info.plist 中的 GADApplicationIdentifier 配置正确
- 确认 Swift 文件已正确添加到项目

### 问题：编译错误
- 确认 google_mobile_ads 插件已在 pubspec.yaml 中正确配置
- 运行 `flutter clean && flutter pub get`
- 运行 `cd ios && pod install`

### 问题：找不到 GADNativeAdView
- 确认已运行 `pod install`
- 清理项目重新构建

## 与Android对比
- Android: 使用 XML 布局文件 (`native_ad_layout.xml`)
- iOS: 使用 XIB 布局文件 (`NativeAdView.xib`)
- 布局设计保持一致，确保跨平台体验统一

## 下一步
完成上述手动步骤后，iOS平台的原生广告就可以正常工作了！

