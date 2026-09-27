#!/bin/bash
set -euo pipefail

SQLITE3="/home/ubuntu/miniconda3/bin/sqlite3"
DB_FILE="/home/ubuntu/tech-learn/backend/history.db"
BACKUP_DIR="/home/ubuntu/backups"
KEEP_DAYS=7

mkdir -p "$BACKUP_DIR"

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$BACKUP_DIR/history-$STAMP.db"

"$SQLITE3" "$DB_FILE" ".backup '$OUT'"

if [ ! -s "$OUT" ]; then
    echo "备份文件为空：$OUT" >&2
    exit 1
fi

COUNT=$("$SQLITE3" "$OUT" "SELECT COUNT(*) FROM history;")
echo "$(date '+%F %T') 备份完成：$OUT（$COUNT 条记录）"

find "$BACKUP_DIR" -name 'history-*.db' -mtime +$KEEP_DAYS -delete
