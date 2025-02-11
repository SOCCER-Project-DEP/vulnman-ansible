#!/bin/bash

set -e
success=false

backup_dir="/var/backups/postgres"
mkdir -p "$backup_dir"
backup_file="$backup_dir/$(date +%Y-%m-%d_%H-%M-%S).sql"

onexit() {
    if [ "$success" = true ]; then
        send-notification "Postgres backup" "Completed successfully ✅"
    else
        send-notification "Postgres backup" "**Backup failed** ❌"
    fi
}
trap onexit EXIT

send-notification "Postgres backup" "Started"

docker exec -t postgres_db pg_dumpall -c -U postgres >"$backup_file"

if [ $? -ne 0 ]; then
    exit 1
fi

cleanup_old_backups() {
    local backups=("$backup_dir"/*.sql)
    local count=${#backups[@]}

    if [ "$count" -gt 10 ]; then
        oldest_backup=$(ls -t "$backup_dir"/*.sql | tail -1)
        rm -f "$oldest_backup"
    fi
}

cleanup_old_backups

success=true
exit 0
