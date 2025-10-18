# iOS 原生广告设置完成指南

## ✅ 已完成的工作

我已经为iOS平台创建了原生广告的完整实现：

### 1. 创建的文件
- ✅ `ios/Runner/NativeAdFactory.swift` - 原生广告工厂类
- ✅ `ios/Runner/NativeAdView.xib` - 原生广告UI布局文件
- ✅ 更新了 `ios/Runner/AppDelegate.swift` - 添加了广告工厂注册代码
- ✅ 运行了 `pod install` 更新iOS依赖

### 2. 功能特性
原生广告布局包含以下元素（与Android版本保持一致）：
- 广告标识徽章
- 广告标题（最多2行）
- 广告描述（最多2行）
- 应用图标（24x24dp）
- 媒体视图（150x150dp）- 显示图片或视频
- 评分星级
- 广告商名称
- 操作按钮（安装/下载等）

## 🔧 需要手动完成的步骤

由于Xcode项目文件的特殊性，需要您手动将Swift文件添加到Xcode项目中：

### 步骤1: 打开Xcode项目
```bash
cd /Users/litengda/Documents/Dev/glitrip/app
open ios/Runner.xcworkspace
```

### 步骤2: 添加Swift文件到项目
1. 在Xcode左侧的项目导航器中，找到 `Runner` 文件夹
2. 右键点击 `Runner` 文件夹，选择 **"Add Files to Runner..."**
3. 在弹出的文件选择器中，导航到 `ios/Runner/` 目录
4. **按住Command键**，同时选择以下两个文件：
   - `NativeAdFactory.swift`
   - `NativeAdView.xib`
5. 在对话框底部，确保以下选项被勾选：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**（不是Create folder references）
   - ✅ **Add to targets**: 勾选 **Runner**
6. 点击 **"Add"** 按钮

### 步骤3: 验证配置（可选）
1. 在项目导航器中，您应该能看到新添加的两个文件出现在 Runner 组中
2. 点击 `NativeAdView.xib` 文件，确认能在右侧看到界面预览
3. 点击 `NativeAdFactory.swift` 文件，确认代码正常显示

### 步骤4: 构建测试
```bash
# 清理项目
flutter clean
flutter pub get

# 构建iOS应用
flutter build ios --debug
```

或者直接在Xcode中点击 **Product > Build** (⌘B)

## 📱 测试原生广告

1. 运行应用到iOS模拟器或真机
2. 进入"文档"页面
3. 添加至少**2个文档**（原生广告会在第二个文档分组后显示）
4. 向下滚动查看原生广告

## 🔍 当前使用的测试广告ID

```dart
// lib/ad_helper.dart 中已配置
iOS原生广告测试ID: ca-app-pub-3940256099942544/3986624511
```

⚠️ **重要提示**：这是Google AdMob的测试广告ID，正式发布前需要替换为您自己的广告单元ID！

## ⚙️ 技术实现详情

### 广告工厂注册（AppDelegate.swift）
```swift
// 在应用启动时注册
let nativeAdFactory = NativeAdFactory()
FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
    self, factoryId: "listTile", nativeAdFactory: nativeAdFactory)

// 在应用终止时取消注册
FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: "listTile")
```

### 广告加载（documents_page.dart）
```dart
_nativeAd = NativeAd(
  adUnitId: AdHelper.nativeAdUnitId,
  factoryId: 'listTile', // 对应iOS和Android的工厂ID
  request: const AdRequest(),
  listener: NativeAdListener(...),
);
```

## 🐛 常见问题解决

### 问题1: 找不到 GADNativeAdView 类型
**解决方案**：确保已运行 `pod install`，清理并重新构建项目
```bash
cd ios && pod install
cd .. && flutter clean && flutter pub get
```

### 问题2: 广告不显示
**可能原因**：
- 文档数量不足（需要至少2个文档分组才会显示广告）
- 网络连接问题
- 广告加载失败（查看Xcode控制台日志）

**解决方案**：
- 检查文档列表是否有足够的数据
- 查看控制台中的广告加载日志
- 确认网络连接正常

### 问题3: Xcode编译错误
**解决方案**：
1. 确认Swift文件已正确添加到项目
2. 检查 Bridging Header 配置
3. 清理派生数据：Product > Clean Build Folder (⇧⌘K)

## ✨ 完成后的效果

iOS平台的原生广告将：
- 与Android平台保持一致的视觉效果
- 自然地融入文档列表中
- 显示在第二个文档分组后
- 包含完整的广告元素（标题、描述、图片、按钮等）
- 遵循AdMob的广告政策要求

## 📋 对比Android实现

| 方面 | Android | iOS |
|------|---------|-----|
| 布局文件 | native_ad_layout.xml | NativeAdView.xib |
| 工厂类 | NativeAdFactoryExample.kt | NativeAdFactory.swift |
| 注册位置 | MainActivity.kt | AppDelegate.swift |
| 工厂ID | "listTile" | "listTile" |
| UI风格 | 完全一致 | 完全一致 |

## 🎉 总结

完成上述手动步骤后，您的iOS应用就可以正常显示原生广告了！如果遇到任何问题，请参考上面的故障排查部分。

---

**需要帮助？** 
- 查看详细的英文说明：`ios/IOS_NATIVE_AD_SETUP.md`
- 查看Flutter文档：https://pub.dev/packages/google_mobile_ads
- 查看AdMob文档：https://developers.google.com/admob/ios/native

