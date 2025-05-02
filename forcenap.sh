#!/bin/bash
#
# 强制启用 App Nap（万无一失版）
# 作者：Logos for 斯卡蒂大人
#

set -euo pipefail
IFS=$'\n'

BACKUP_ROOT="$HOME/AppNapBackup"
LOG_FILE="$HOME/AppNapBackup/appnap_fix_$(date +%Y%m%d_%H%M%S).log"
APP_PATHS=(
  "/Applications"
  "/Applications/Utilities"
  "$HOME/Applications"
)

echo "📔 日志记录：$LOG_FILE"
mkdir -p "$BACKUP_ROOT"
touch "$LOG_FILE"

function log() { echo "$1" | tee -a "$LOG_FILE"; }

for DIR in "${APP_PATHS[@]}"; do
  [ -d "$DIR" ] || continue
  log "🔍 扫描目录: $DIR"

  find "$DIR" -name "Info.plist" 2>/dev/null | while read -r plist; do
    if /usr/libexec/PlistBuddy -c "Print NSAppSleepDisabled" "$plist" 2>/dev/null | grep -q "true"; then
      APP_PATH=$(echo "$plist" | sed -E 's|(.*\.app).*|\1|')
      APP_NAME=$(basename "$APP_PATH")

      # 备份
      RELATIVE=$(echo "$plist" | sed -E "s|^/||")
      BACKUP_PATH="$BACKUP_ROOT/$RELATIVE"
      mkdir -p "$(dirname "$BACKUP_PATH")"
      cp "$plist" "$BACKUP_PATH"

      # 修改
      sudo /usr/libexec/PlistBuddy -c "Delete NSAppSleepDisabled" "$plist"

      # 重签名
      sudo codesign --force --deep -s - "$APP_PATH" >/dev/null 2>&1

      log "✅ 已修复并重签名：$APP_NAME"
    fi
  done
done

log "🎉 全部处理完成！如需回滚请执行 restore_appnap_backup.sh"
