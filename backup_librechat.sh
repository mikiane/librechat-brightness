#!/usr/bin/env bash
# backup_librechat.sh
# Script de sauvegarde complète pour une instance LibreChat déployée en Docker Compose

set -euo pipefail

### Chargement des variables d'environnement depuis .env si présent ###
if [ -f .env ]; then
  echo "⏳ Chargement des variables d'environnement depuis .env"
  set -o allexport
  source .env
  set +o allexport
fi

### CONFIGURATION – adapté à votre environnement ###
# Répertoire où stocker les backups (par défaut le répertoire courant)
BACKUP_BASE_DIR="${BACKUP_BASE_DIR:-.}"

# Noms des conteneurs Docker (service par défaut LibreChat)
MONGO_CONTAINER="${MONGO_CONTAINER:-chat-mongodb}"
PG_CONTAINER="${PG_CONTAINER:-vectordb}"

# Paramètres PostgreSQL (chargés depuis .env si présents)
PG_USER="${PG_USER:-${POSTGRES_USER:-}}
PG_DB="${PG_DB:-${POSTGRES_DB:-}}"

# Volumes Docker à sauvegarder (modifiez si besoin)
VOLUMES=("librechat_uploads")

# Fichiers de config à copier (dans la racine du projet)
CONFIG_FILES=(".env" "docker-compose.yml")

# Rétention : supprimer les backups de plus de N jours (mettre 0 pour désactiver)
RETENTION_DAYS=30
### FIN DE LA CONFIG ###

TIMESTAMP="$(date +'%Y-%m-%d_%Hh%M')"
BACKUP_DIR="$BACKUP_BASE_DIR/backup_$TIMESTAMP"

echo "🗃️  Démarrage du backup LibreChat : $TIMESTAMP"

# Création du répertoire de backup
mkdir -p "$BACKUP_DIR"

# 1. Sauvegarde MongoDB (sans authentification)
echo "  • Sauvegarde MongoDB ($MONGO_CONTAINER)…"
docker exec -i "$MONGO_CONTAINER" \
  mongodump --archive --gzip --db LibreChat \
  > "$BACKUP_DIR/mongo_LibreChat_$TIMESTAMP.gz"

# 2. Sauvegarde PostgreSQL vectordb (sans mot de passe)
echo "  • Sauvegarde PostgreSQL ($PG_CONTAINER)…"
if [ -z "$PG_DB" ]; then
  echo "    ⚠️  POSTGRES_DB non défini, passez-le via .env ou variable PG_DB"
else
  dump_cmd="pg_dump"
  if [ -n "$PG_USER" ]; then
    dump_cmd="$dump_cmd --username=$PG_USER"
  fi
  dump_cmd="$dump_cmd --dbname=$PG_DB"
  docker exec -i "$PG_CONTAINER" bash -c "$dump_cmd" \
    > "$BACKUP_DIR/postgres_vectordb_$TIMESTAMP.sql"
fi

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
    -mtime +"$RETENTION_DAYS" -exec rm -rf {} \\;
fi

echo "✅ Backup terminé. Fichiers stockés dans $BACKUP_DIR"
