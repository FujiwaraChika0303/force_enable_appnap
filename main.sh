#!/bin/bash

echo "🌿 正在扫描 App 是否禁用了 App Nap..."

# 支持的应用目录
APP_PATHS=(
  "/Applications"
  "/Applications/Utilities"
  "$HOME/Applications"
)

# 开始扫描
for DIR in "${APP_PATHS[@]}"; do
  echo "📁 扫描目录: $DIR"
  find "$DIR" -name "Info.plist" 2>/dev/null | while read plist; do
    if /usr/libexec/PlistBuddy -c "Print NSAppSleepDisabled" "$plist" 2>/dev/null | grep -q "true"; then
      # 获取 App 名称
      appname=$(echo "$plist" | sed -E 's|.*/([^/]+)\.app/.*|\1|')

      echo ""
      echo "⚠️ 检测到 App 禁用了 App Nap：$appname"
      echo "   路径：$plist"
      read -p "👉 是否强制启用 App Nap（y/n）？" yn
      if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo /usr/libexec/PlistBuddy -c "Delete NSAppSleepDisabled" "$plist"
        echo "✅ 已移除禁用设置：$appname"
      else
        echo "⏭️ 跳过：$appname"
      fi
    fi
  done
done

echo ""
echo "✅ 扫描完毕。建议重新启动已修改的 App 以生效。"
