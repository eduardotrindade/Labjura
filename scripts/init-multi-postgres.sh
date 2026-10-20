#!/bin/bash
set -e

# Cria os bancos e usuários múltiplos no PostgreSQL para InvenTree e Chatwoot
function create_user_and_database() {
	local database=$1
	local user=$2
	local password=$3
	echo "Criando usuário '$user' e banco '$database'..."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    DO \$\$
	    BEGIN
	        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$user') THEN
	            CREATE USER $user WITH ENCRYPTED PASSWORD '$password';
	        END IF;
	    END
	    \$\$;
	    SELECT 'CREATE DATABASE $database OWNER $user'
	    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database')\gexec
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
}

if [ -n "$INVENTREE_DB_NAME" ] && [ -n "$INVENTREE_DB_USER" ]; then
    create_user_and_database "$INVENTREE_DB_NAME" "$INVENTREE_DB_USER" "$INVENTREE_DB_PASSWORD"
fi

if [ -n "$CHATWOOT_DB_NAME" ] && [ -n "$CHATWOOT_DB_USER" ]; then
    create_user_and_database "$CHATWOOT_DB_NAME" "$CHATWOOT_DB_USER" "$CHATWOOT_DB_PASSWORD"
fi

echo "PostgreSQL multi-database inicializado com sucesso!"
