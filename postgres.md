# Postgres

## Playbook prod_database

This playbook sets up a postgres database in a docker container.

Use this for production setups.

Password is randomly generated and stored in `/opt/db/db_pass`
Use role `prod_db_creds` to get the password as `db_pass` variable into your playbooks.

This does not protect the password from being read by other users on the same machine, only against accidental exposure of db to the internet.

Backups are either in form of sql dumps in `/var/backups/postgres` or in form of a volume mounted to `/postgres_db`.
