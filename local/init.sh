echo "[ISLE DC] Starting ISLE..."
docker-compose up -d
echo "[ISLE DC] make install..."
make install
echo "[ISLE DC] updating/managing settings..."
make update-settings-php update-config-from-environment solr-cores run-islandora-migrations
echo "[ISLE DC] rebuilding Drupal cache..."
docker-compose exec drupal drush cr -y
