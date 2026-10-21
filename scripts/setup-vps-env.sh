#!/bin/bash
set -e

cd /opt/labjura
chmod +x scripts/init-multi-postgres.sh

# Gerar segredos aleatorios de producao
MARIADB_PASS=$(openssl rand -hex 16)
POSTGRES_PASS=$(openssl rand -hex 16)
INVENTREE_DB_PASS=$(openssl rand -hex 16)
CHATWOOT_DB_PASS=$(openssl rand -hex 16)
REDIS_PASS=$(openssl rand -hex 16)
INV_SEC=$(openssl rand -hex 24)
INV_ADMIN_PASS=$(openssl rand -hex 12)
CW_SEC=$(openssl rand -hex 32)

sed -i "s/mariadb_root_secret_change_me/$MARIADB_PASS/g" .env
sed -i "s/glpi_password_change_me/$MARIADB_PASS/g" .env
sed -i "s/postgres_master_secret_change_me/$POSTGRES_PASS/g" .env
sed -i "s/inventree_secret_change_me/$INVENTREE_DB_PASS/g" .env
sed -i "s/chatwoot_secret_change_me/$CHATWOOT_DB_PASS/g" .env
sed -i "s/redis_secret_change_me/$REDIS_PASS/g" .env
sed -i "s/inventree_generate_a_random_secret_key_here/$INV_SEC/g" .env
sed -i "s/admin_password_change_me/$INV_ADMIN_PASS/g" .env
sed -i "s/chatwoot_generate_a_secure_random_hex_string_64_bytes/$CW_SEC/g" .env

# Portas seguras no localhost da VPS
sed -i "s/PORT_GLPI=8080/PORT_GLPI=127.0.0.1:18880/g" .env
sed -i "s/PORT_INVENTREE=8081/PORT_INVENTREE=127.0.0.1:18881/g" .env
sed -i "s/PORT_CHATWOOT=3000/PORT_CHATWOOT=127.0.0.1:18882/g" .env

echo "=== AMBIENTE VPS CONFIGURADO COM SUCESSO ==="
echo "PORT_GLPI: 127.0.0.1:18880"
echo "PORT_INVENTREE: 127.0.0.1:18881"
echo "PORT_CHATWOOT: 127.0.0.1:18882"
echo "INVENTREE ADMIN USER: admin"
echo "INVENTREE ADMIN PASS: $INV_ADMIN_PASS"
