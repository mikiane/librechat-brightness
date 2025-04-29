#!/usr/bin/env bash
# backup_librechat.sh
# Script de sauvegarde complète pour une instance LibreChat déployée en Docker Compose

set -euo pipefail

### CONFIGURATION – adapté à votre environnement ###

# Répertoire où stocker les backups
BACKUP_BASE_DIR="${BACKUP_BASE_DIR:-/var/backups/librechat}"

# Noms des conteneurs Docker
MONGO_CONTAINER="${MONGO_CONTAINER:-chat-mongodb}"
PG_CONTAINER="${PG_CONTAINER:-vectordb}"

# Paramètres PostgreSQL (on suppose que ces variables sont définies dans votre .env)
PG_USER="${PG_USER:-$POSTGRES_USER}"
PG_DB="${PG_DB:-$POSTGRES_DB}"
PG_PASSWORD="${PG_PASSWORD:-$POSTGRES_PASSWORD}"

# Volumes Docker à sauvegarder (modifiez la liste si vous en avez d’autres)
VOLUMES=("librechat_uploads")

# Fichiers de config à copier (dans la racine de votre projet)
CONFIG_FILES=(".env" "docker-compose.yml")

# Rétention : supprimer les backups de plus de N jours (mettre 0 pour désactiver)
RETENTION_DAYS=30

### FIN DE LA CONFIG ###

TIMESTAMP="$(date +'%Y-%m-%d_%Hh%M')" 
BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"

echo "🗃️  Démarrage du backup LibreChat : $TIMESTAMP"

# Création du répertoire de backup
mkdir -p "$BACKUP_DIR"

# 1. Sauvegarde MongoDB
echo "  • Sauvegarde MongoDB ($MONGO_CONTAINER)…"
docker exec -i "$MONGO_CONTAINER" \
  mongodump --archive --gzip --db LibreChat \
  > "$BACKUP_DIR/mongo_LibreChat_$TIMESTAMP.gz"

# 2. Sauvegarde PostgreSQL vectordb
echo "  • Sauvegarde PostgreSQL ($PG_CONTAINER)…"
docker exec -i "$PG_CONTAINER" /bin/bash -c \
  "export PGPASSWORD='$PG_PASSWORD'; pg_dump --username='$PG_USER' --dbname='$PG_DB'" \
  > "$BACKUP_DIR/postgres_vectordb_$TIMESTAMP.sql"

# 3. Sauvegarde des volumes Docker
for vol in "${VOLUMES[@]}"; do
  echo "  • Sauvegarde volume Docker : $vol"
  docker run --rm \
    -v "$vol":/data \
    -v "$BACKUP_DIR":/backup \
    alpine sh -c "tar czf /backup/vol_${vol}_$TIMESTAMP.tgz -C /data ."
done

# 4. Copie des fichiers de configuration
echo "  • Copie des fichiers de configuration"
for f in "${CONFIG_FILES[@]}"; do
  if [ -f "$f" ]; then
    cp "$f" "$BACKUP_DIR/"
  else
    echo "    ⚠️  Fichier non trouvé : $f"
  fi
done

# 5. Nettoyage des anciens backups
if [ "$RETENTION_DAYS" -gt 0 ]; then
  echo "  • Nettoyage des backups de plus de $RETENTION_DAYS jours"
  find "$BACKUP_BASE_DIR" -maxdepth 1 -type d \
    -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
fi

echo "✅ Backup terminé. Fichiers stockés dans $BACKUP_DIR"
