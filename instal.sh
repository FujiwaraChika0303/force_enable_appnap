#!/bin/bash
#
# 🌙 AppFN By KurisuRakko – All‑in‑One (CN/EN)
# Version 1.0.0
# --------------------------------------------

APPFN_VERSION="1.0.0"
BACKUP_DIR="$HOME/AppNapBackup"
FORCE_NAP="$HOME/forcenap.sh"
RESTORE_NAP="$HOME/restore_appnap_backup.sh"
SELF_SCRIPT="$HOME/AppFN.sh"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/FujiwaraChika0303/force_enable_appnap/refs/heads/main"

# ========== 小工具 ==========
cn() { echo -e "$1" ; }               # 打印中文
en() { echo -e "$2" ; }               # 打印英文
sep() { echo "----------------------------------------"; }
pause() { read -rp ">> "; }

# ========== 菜单 ==========
show_menu() {
  echo ""
  echo "🌙  AppFN By KurisuRakko – v$APPFN_VERSION"
  echo "========================================"
  echo "1) 强制启用 App Nap / Enable App Nap"
  echo "2) 回滚所有修改    / Rollback changes"
  echo "3) 查看最近日志    / View latest log"
  echo "4) 检查并更新脚本  / Update AppFN"
  echo "5) 卸载 AppFN      / Uninstall AppFN"
  echo "6) 退出            / Exit"
  echo ""
}

# ========== 功能实现 ==========
enable_appnap() {
  sep
  cn "🛠 正在启用 App Nap..."        en "🛠 Enabling App Nap..."
  sudo force_enable_appnap
  sep
  cn "✅ 操作完成。"                en "✅ Done."
  pause
}

rollback_appnap() {
  sep
  cn "↩️ 正在回滚修改..."           en "↩️ Rolling back..."
  sudo restore_appnap
  sep
  cn "✅ 回滚完成。"                en "✅ Rollback done."
  pause
}

view_latest_log() {
  sep
  LATEST_LOG=$(ls -t "$BACKUP_DIR"/*.log 2>/dev/null | head -n 1)
  if [[ -f "$LATEST_LOG" ]]; then
    cn "📄 最近日志："               en "📄 Latest log:"
    echo "$LATEST_LOG"
    sep
    cat "$LATEST_LOG"
  else
    cn "⚠️ 未找到日志。"            en "⚠️ No log found."
  fi
  pause
}

update_appfn() {
  sep
  cn "🌐 正在更新脚本..."           en "🌐 Updating scripts..."
  curl -L "$GITHUB_RAW_BASE/forcenap.sh"              -o "$FORCE_NAP"
  curl -L "$GITHUB_RAW_BASE/restore_appnap_backup.sh" -o "$RESTORE_NAP"
  curl -L "$GITHUB_RAW_BASE/AppFN.sh"                 -o "$SELF_SCRIPT"
  chmod +x "$FORCE_NAP" "$RESTORE_NAP" "$SELF_SCRIPT"
  cn "✅ 更新完成。"                en "✅ Update finished."
  sep
  cn "是否重建命令链接？(y/n)"      en "Re‑create symlinks? (y/n)"
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo ln -sf "$FORCE_NAP"   /usr/local/bin/force_enable_appnap
    sudo ln -sf "$RESTORE_NAP" /usr/local/bin/restore_appnap
    sudo ln -sf "$SELF_SCRIPT" /usr/local/bin/appfn
    cn "✅ 链接已更新。"            en "✅ Symlinks updated."
  fi
  pause
}

uninstall_appfn() {
  sep
  cn "⚠️ 即将卸载 AppFN，并可选择是否删除备份。" \
     en "⚠️ About to uninstall AppFN. You may also delete backups."
  cn "确定卸载？(y/n)"             en "Proceed? (y/n)"
  read -r yesno
  if [[ "$yesno" =~ ^[Yy]$ ]]; then
    sudo rm -f /usr/local/bin/force_enable_appnap /usr/local/bin/restore_appnap /usr/local/bin/appfn
    rm -f "$FORCE_NAP" "$RESTORE_NAP" "$SELF_SCRIPT"
    cn "是否删除所有备份日志？(y/n)" \
       en "Delete all backup & log files? (y/n)"
    read -r delbk
    if [[ "$delbk" =~ ^[Yy]$ ]]; then
      rm -rf "$BACKUP_DIR"
      cn "🗑 已删除备份与日志。"     en "🗑 Backups & logs removed."
    fi
    cn "✅ 卸载完成，再见！"        en "✅ Uninstall complete. Bye!"
   
