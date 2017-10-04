#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

nginx_exec() {
    docker-compose -f test/docker-compose.yml exec nginx "${@}"
}

docker-compose -f test/docker-compose.yml up -d

nginx_exec make check-ready -f /usr/local/bin/actions.mk

# TODO: check endpoints of installed Drupal

echo "Checking Drupal endpoints"
echo -n "Checking / page... "
nginx_exec curl -I "localhost" | grep '302 Found'
echo -n "authorize.php...   "
nginx_exec curl -I "localhost/core/authorize.php" | grep '500 Service unavailable'
echo -n "install.php...     "
nginx_exec curl -I "localhost/core/install.php" | grep '200 OK'
echo -n "statistics.php...  "
nginx_exec curl -I "localhost/core/modules/statistics/statistics.php" | grep '500 Service unavailable'
echo -n "cron...            "
nginx_exec curl -I "localhost/cron" | grep '200 OK'
echo -n "index.php...       "
nginx_exec curl -I "localhost/index.php" | grep '302 Found'
echo -n "update.php...      "
nginx_exec curl -I "localhost/update.php" | grep '500 Service unavailable'
echo -n ".htaccess...       "
nginx_exec curl -I "localhost/.htaccess" | grep '404 Not Found'
echo -n "favicon.ico...     "
nginx_exec curl -I "localhost/favicon.ico" | grep '200 OK'
echo -n "robots.txt...      "
nginx_exec curl -I "localhost/robots.txt" | grep '200 OK'
echo -n "drupal.js...       "
nginx_exec curl -I "localhost/core/misc/drupal.js" | grep '200 OK'
echo -n "druplicon.png...   "
nginx_exec curl -I "localhost/core/misc/druplicon.png" | grep '200 OK'

echo -n "Checking non existing php endpoint... "
nginx_exec curl -I "localhost/non-existing.php" | grep '404 Not Found'
echo -n "Checking user-defined internal temporal redirect... "
nginx_exec curl -I "localhost/redirect-internal-temporal" | grep '302 Moved Temporarily'
echo -n "Checking user-defined internal permanent redirect... "
nginx_exec curl -I "localhost/redirect-internal-permanent" | grep '301 Moved Permanently'
echo -n "Checking user-defined external redirect... "
nginx_exec curl -I "localhost/redirect-external" | grep '302 Moved Temporarily'

docker-compose -f test/docker-compose.yml down