#!/bin/sh
set -eu
START_DATETIME=$(date --utc "+%Y-%m-%d %H:%M:%SZ")
UUID=$(python -c "import uuid; print(uuid.uuid4())")
cd -- "tests/example/backup"
git init
(
    cd example.com_22_jane
    (
        cd dir_home_jane_public
        rsync -avzP --delete-delay -e "ssh -p 22" jane@example.com:/home/jane/public/ data/
    )
    (
        cd mysql_joomla
        ssh -p 22 jane@example.com -- "
            set -eu
            (
                mysqldump --no-data joomla
                mysqldump --no-create-info --skip-extended-insert --complete-insert --ignore-table joomla.j_session joomla
            ) | egrep -v ^--.Dump.completed.on > /tmp/mysql_joomla_$UUID.sql"
        rsync -avzP --delete-delay -e "ssh -p 22" jane@example.com:"/tmp/mysql_joomla_$UUID.sql" dump.sql
        ssh -p 22 jane@example.com -- "
            set -eu
            rm -f /tmp/mysql_joomla_$UUID.sql"
    )
    (
        cd pgsql_redmine
        ssh -p 22 jane@example.com -- "
            set -eu
            pg_dump redmine > /tmp/pgsql_redmine_$UUID.sql"
        rsync -avzP --delete-delay -e "ssh -p 22" jane@example.com:"/tmp/pgsql_redmine_$UUID.sql" dump.sql
        ssh -p 22 jane@example.com -- "
            set -eu
            rm -f /tmp/pgsql_redmine_$UUID.sql"
    )
    (
        cd pgsql_test
        ssh -p 22 jane@example.com -- "
            set -eu
            pg_dump --exclude-table-data garbage --exclude-table-data useless test > /tmp/pgsql_test_$UUID.sql"
        rsync -avzP --delete-delay -e "ssh -p 22" jane@example.com:"/tmp/pgsql_test_$UUID.sql" dump.sql
        ssh -p 22 jane@example.com -- "
            set -eu
            rm -f /tmp/pgsql_test_$UUID.sql"
    )
)
(
    cd example.com_22_root
    (
        cd dir_etc_apache2
        rsync -avzP --delete-delay -e "ssh -p 22" root@example.com:/etc/apache2/ data/
    )
    (
        cd dir_etc_cron.d
        rsync -avzP --delete-delay -e "ssh -p 22" root@example.com:/etc/cron.d/ data/
    )
)
END_DATETIME=$(date --utc "+%Y-%m-%d %H:%M:%SZ")
git add .
git diff-index --quiet HEAD || git -c user.name="Website Backup (wsb)" -c user.email="wsb@localhost" commit -am "Backup $START_DATETIME - $END_DATETIME"
