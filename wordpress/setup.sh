#!/bin/sh
set -e

ELEMENTOR_VERSION="4.1.1"
EDWISER_BRIDGE_VERSION="4.3.4"

echo "[wp-setup] Waiting for WordPress files..."
until [ -f /var/www/html/wp-load.php ]; do
  sleep 2
done

echo "[wp-setup] Waiting for database..."
until wp db check --path=/var/www/html --allow-root 2>/dev/null; do
  sleep 3
done

if wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
  echo "[wp-setup] WordPress already installed, skipping core install."
else
  echo "[wp-setup] Installing WordPress core..."
  wp core install \
    --path=/var/www/html \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --allow-root
fi

echo "[wp-setup] Fixing wp-content permissions..."
chown -R 33:33 /var/www/html/wp-content/plugins
chown -R 33:33 /var/www/html/wp-content/themes
chown -R 33:33 /var/www/html/wp-content/uploads
mkdir -p /var/www/html/wp-content/upgrade && chown -R 33:33 /var/www/html/wp-content/upgrade

echo "[wp-setup] Installing plugins..."
wp plugin install elementor --version="${ELEMENTOR_VERSION}" --activate --path=/var/www/html --allow-root
wp plugin install edwiser-bridge --version="${EDWISER_BRIDGE_VERSION}" --activate --path=/var/www/html --allow-root
wp plugin activate aquinas-mailer --path=/var/www/html --allow-root || true

echo "[wp-setup] Done."
