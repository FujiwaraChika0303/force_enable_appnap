#!/bin/bash
#
# 回滚 App Nap 修改
#

BACKUP_ROOT="$HOME/AppNapBackup"
[ -d "$BACKUP_ROOT" ] || { echo "❌ 未找到备份目录 $BACKUP_ROOT"; exit 1; }

find "$BACKUP_ROOT" -name "Info.plist" | while read -r backup; do
  ORIGINAL="/$(echo "$backup" | sed -E "s|$BACKUP_ROOT/||")"
  if [ -f "$ORIGINAL" ]; then
    sudo cp "$backup" "$ORIGINAL"
    APP_PATH=$(echo "$ORIGINAL" | sed -E 's|(.*\.app).*|\1|')
    sudo codesign --force --deep -s - "$APP_PATH" >/dev/null 2>&1
    echo "↩️ 已还原：$APP_PATH"
  fi
done

echo "🔄 回滚完成，请重启相关应用。"
