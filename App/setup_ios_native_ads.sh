#!/bin/bash

# iOS原生广告设置辅助脚本

echo "================================================"
echo "  iOS原生广告设置向导"
echo "================================================"
echo ""
echo "✅ 已完成的工作："
echo "  - 创建 NativeAdFactory.swift"
echo "  - 创建 NativeAdView.xib"
echo "  - 更新 AppDelegate.swift"
echo "  - 运行 pod install"
echo ""
echo "🔧 需要手动完成："
echo "  将Swift文件添加到Xcode项目中"
echo ""
echo "📖 详细步骤请查看："
echo "  IOS原生广告设置说明.md"
echo ""
echo "================================================"
echo ""
read -p "是否现在打开Xcode项目？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "正在打开Xcode项目..."
    open ios/Runner.xcworkspace
    echo ""
    echo "✨ 接下来的步骤："
    echo ""
    echo "1. 在Xcode左侧找到 Runner 文件夹"
    echo "2. 右键点击 Runner → 选择 'Add Files to Runner...'"
    echo "3. 选择以下两个文件："
    echo "   - ios/Runner/NativeAdFactory.swift"
    echo "   - ios/Runner/NativeAdView.xib"
    echo "4. 确保勾选："
    echo "   ✅ Copy items if needed"
    echo "   ✅ Create groups"
    echo "   ✅ Add to targets: Runner"
    echo "5. 点击 Add 按钮"
    echo ""
    echo "完成后，您就可以构建并测试应用了！"
    echo ""
else
    echo "已取消。您可以稍后手动打开项目："
    echo "  open ios/Runner.xcworkspace"
fi

echo ""
echo "================================================"

