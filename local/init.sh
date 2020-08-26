#!/bin/bash
source repos.conf
git clean -fdX
ISLE_BRANCH=${ISLE_BRANCH:-development}
ISLE_REPO=${ISLE_REPO:-}

function checkout { # checkout $repo $branch $into_dir
  local REPO=$1
  local BRANCH=$2
  local DIR=$3
  if [ -d $DIR ]; then
    (cd $DIR; git checkout $BRANCH || exit )
  else
    git clone --branch $BRANCH $REPO $DIR || exit
  fi
}

echo "[ISLE DC] Checking out ISLE"
checkout $ISLE_REPO $ISLE_BRANCH .isle
checkout $DRUPAL_SITE_REPO $DRUPAL_SITE_BRANCH codebase

cp -r .isle/* .
make
if [[ $(docker-compose ps -q) ]] ; then
	docker-compose down -v
fi

echo "[ISLE DC] Starting ISLE..."
docker-compose up -d
echo "[ISLE DC] Composer install..."
docker-compose exec drupal with-contenv bash -lc 'COMPOSER_MEMORY_LIMIT=-1 composer install'
echo "[ISLE DC] make install..."
make install
echo "[ISLE DC] updating/managing settings..."
make update-settings-php update-config-from-environment solr-cores run-islandora-migrations
echo "[ISLE DC] rebuilding Drupal cache..."
docker-compose exec drupal drush cr -y
