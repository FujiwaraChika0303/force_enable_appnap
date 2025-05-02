#!/bin/bash
# ================================================================
# 🌙 AppFN By KurisuRakko – Manager Script (更新 & 回滚)
# 该脚本只负责兩件事：
#   1. 從 GitHub 拉取最新的 App Nap 强制脚本 (forcenap.sh)
#      與回滚脚本 (restore_appnap_backup.sh)
#   2. 一鍵回滚所有已修改的 Info.plist（還原備份）
# ================================================================
# Version
APPFN_MANAGER_VER="1.0.0"

# GitHub Raw base (adjust if you fork / mirror)
RAW_BASE="https://raw.githubusercontent.com/FujiwaraChika0303/force_enable_appnap/main"

# Local paths
FORCE_NAP="$HOME/forcenap.sh"
RESTORE_NAP="$HOME/restore_appnap_backup.sh"
BACKUP_DIR="$HOME/AppNapBackup"

# Helper: divider line
sep() { echo "----------------------------------------------"; }

# Helper: pause and wait for <Enter>
pause() { read -rp "[Enter] 继续 / Continue..."; }

# ===== Action: Update scripts =====
update_scripts() {
  sep
  echo "🌐 正在下载最新版脚本 / Downloading latest scripts...";

  curl -fsSL "$RAW_BASE/forcenap.sh" \
    -o "$FORCE_NAP" && echo "✅ forcenap.sh 已更新 / Updated" || {
      echo "❌ 无法下载 forcenap.sh"; return 1; }

  curl -fsSL "$RAW_BASE/restore_appnap_backup.sh" \
    -o "$RESTORE_NAP" && echo "✅ restore_appnap_backup.sh 已更新 / Updated" || {
      echo "❌ 无法下载 restore_appnap_backup.sh"; return 1; }

  chmod +x "$FORCE_NAP" "$RESTORE_NAP"

  # (可选) 重新建立软链 – 只有在不存在时创建
  if ! command -v force_enable_appnap >/dev/null 2>&1; then
    sudo ln -s "$FORCE_NAP" /usr/local/bin/force_enable_appnap 2>/dev/null || true
  fi
  if ! command -v restore_appnap >/dev/null 2>&1; then
    sudo ln -s "$RESTORE_NAP" /usr/local/bin/restore_appnap 2>/dev/null || true
  fi

  sep
  echo "✨ 脚本更新完成 / Scripts updated!"
  pause
}

# ===== Action: Rollback =====
rollback_all() {
  sep
  echo "↩️  正在回滚所有修改 / Rolling back all changes..."
  if [ ! -f "$RESTORE_NAP" ]; then
    echo "❌ 找不到 restore_appnap_backup.sh！请先运行更新。 / restore_appnap_backup.sh missing. Run update first."; pause; return; fi

  sudo "$RESTORE_NAP"
  sep
  echo "✅ 回滚完成 / Rollback done."
  pause
}

# ===== Main Menu Loop =====
while true; do
  clear
  echo "🌙 AppFN Manager – v$APPFN_MANAGER_VER"
  sep
  echo "1) 更新脚本 (forcenap + restore) / Update scripts"
  echo "2) 回滚所有修改 / Rollback changes"
  echo "3) 退出 / Exit"
  sep
  read -rp "请选择 / Select option » " choice
  case "$choice" in
    1) update_scripts ;;
    2) rollback_all   ;;
    3) echo "Bye! 👋"; exit 0 ;;
    *) echo "❌ 无效选项 / Invalid option"; pause ;;
  esac
done
