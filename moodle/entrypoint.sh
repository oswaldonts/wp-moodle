#!/bin/bash
set -e

MOODLE_DIR=/var/www/html

echo "[moodle] Waiting for database..."
until php -r "
\$conn = new mysqli('db', '${MOODLE_DB_USER}', '${MOODLE_DB_PASSWORD}', '${MOODLE_DB_NAME}');
if (\$conn->connect_error) exit(1);
exit(0);
" 2>/dev/null; do
  sleep 3
done

# Check if Moodle is already installed (DB has tables)
DB_INSTALLED=$(php -r "
\$conn = new mysqli('db', '${MOODLE_DB_USER}', '${MOODLE_DB_PASSWORD}', '${MOODLE_DB_NAME}');
\$r = \$conn->query('SHOW TABLES LIKE \"mdl_config\"');
echo \$r->num_rows;
" 2>/dev/null || echo "0")

if [ "${DB_INSTALLED}" = "0" ]; then
  echo "[moodle] Fresh install — running install.php..."
  su -s /bin/bash www-data -c "php ${MOODLE_DIR}/admin/cli/install.php \
    --wwwroot='${MOODLE_WWWROOT}' \
    --dataroot=/var/moodledata \
    --dbtype=mariadb \
    --dbhost=db \
    --dbname='${MOODLE_DB_NAME}' \
    --dbuser='${MOODLE_DB_USER}' \
    --dbpass='${MOODLE_DB_PASSWORD}' \
    --fullname='${MOODLE_SITE_FULLNAME}' \
    --shortname='${MOODLE_SITE_SHORTNAME}' \
    --adminuser='${MOODLE_ADMIN_USER}' \
    --adminpass='${MOODLE_ADMIN_PASSWORD}' \
    --adminemail='${MOODLE_ADMIN_EMAIL}' \
    --non-interactive \
    --agree-license"
else
  echo "[moodle] Existing install detected — generating config.php..."
  su -s /bin/bash www-data -c "cat > ${MOODLE_DIR}/config.php << 'CONFIGEOF'
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();
\$CFG->dbtype    = 'mariadb';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'db';
\$CFG->dbname    = '${MOODLE_DB_NAME}';
\$CFG->dbuser    = '${MOODLE_DB_USER}';
\$CFG->dbpass    = '${MOODLE_DB_PASSWORD}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array('dbpersist' => 0, 'dbport' => '', 'dbsocket' => '', 'dbcollation' => 'utf8mb4_unicode_ci');
\$CFG->wwwroot   = '${MOODLE_WWWROOT}';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';
\$CFG->directorypermissions = 02777;
require_once(__DIR__ . '/lib/setup.php');
CONFIGEOF"
fi

# Copy Edwiser Bridge to auth/ if not already present
if [ ! -d "${MOODLE_DIR}/auth/edwiserbridge" ]; then
  echo "[moodle] Installing Edwiser Bridge plugin..."
  cp -r /opt/edwiserbridge_staging/edwiserbridge ${MOODLE_DIR}/auth/
  chown -R www-data:www-data ${MOODLE_DIR}/auth/edwiserbridge
fi

echo "[moodle] Running upgrade..."
su -s /bin/bash www-data -c "php ${MOODLE_DIR}/admin/cli/upgrade.php --non-interactive"

echo "[moodle] Starting Apache..."
echo "export APACHE_DOCUMENT_ROOT=/var/www/html" >> /etc/apache2/envvars
exec apache2-foreground
