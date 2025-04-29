#!/usr/bin/env bash
# backup_librechat.sh
# Script de sauvegarde complète pour une instance LibreChat déployée en Docker Compose

set -euo pipefail

### Chargement safe des variables d'environnement depuis .env ###
if [ -f .env ]; then
  echo "⏳ Chargement des variables d'environnement depuis .env"
  while IFS= read -r line; do
    # Ignorer commentaires et lignes vides
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ ! "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*= ]] && continue
    export "$line"
  done < .env
fi

### CONFIGURATION – adapté à votre environnement ###
# Répertoire où stocker les backups (par défaut le répertoire courant)
BACKUP_BASE_DIR="${BACKUP_BASE_DIR:-.}"
# Convertit en chemin absolu
ABS_BACKUP_BASE_DIR="$(cd "$BACKUP_BASE_DIR" && pwd)"
# Conteneurs Docker
MONGO_CONTAINER="${MONGO_CONTAINER:-chat-mongodb}"
PG_CONTAINER="${PG_CONTAINER:-vectordb}"
# Paramètres PostgreSQL à récupérer depuis .env
PG_USER="${POSTGRES_USER:-}"
PG_DB="${POSTGRES_DB:-}"

# Volumes Docker à sauvegarder
VOLUMES=("librechat_uploads")
# Fichiers de config à copier\CONFIG_FILES=(".env" "docker-compose.yml")
# Rétention des backups (jours)
RETENTION_DAYS=30

### Vérification des variables PostgreSQL ###
if [ -z "$PG_USER" ] || [ -z "$PG_DB" ]; then
  echo "⚠️  POSTGRES_USER et POSTGRES_DB doivent être définis dans .env"
  echo "    Ignorer la sauvegarde PostgreSQL."
  SKIP_PG=true
else
  SKIP_PG=false
fi

TIMESTAMP="$(date +'%Y-%m-%d_%Hh%M')"
BACKUP_DIR="$ABS_BACKUP_BASE_DIR/backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "🗃️  Démarrage du backup LibreChat : $TIMESTAMP"

# 1. MongoDB
echo "  • Sauvegarde MongoDB ($MONGO_CONTAINER)…"
docker exec -i "$MONGO_CONTAINER" \
  mongodump --archive --gzip --db LibreChat \
  > "$BACKUP_DIR/mongo_LibreChat_$TIMESTAMP.gz"

# 2. PostgreSQL
if [ "$SKIP_PG" = false ]; then
  echo "  • Sauvegarde PostgreSQL ($PG_CONTAINER) base $PG_DB…"
  docker exec -i "$PG_CONTAINER" \
    pg_dump --username="$PG_USER" --dbname="$PG_DB" \
    > "$BACKUP_DIR/postgres_${PG_DB}_$TIMESTAMP.sql"
else
  echo "  • Sauvegarde PostgreSQL sautée"
fi

# 3. Volumes Docker
echo "  • Sauvegarde des volumes Docker"
for vol in "${VOLUMES[@]}"; do
  echo "    - $vol"
  docker run --rm \
    -v "$vol":/data \
    -v "$BACKUP_DIR":/backup \
    alpine sh -c "tar czf /backup/vol_${vol}_${TIMESTAMP}.tgz -C /data ."
done

# 4. Fichiers de config
echo "  • Copie des fichiers de configuration"
for f in "${CONFIG_FILES[@]}"; do
  [ -f "$f" ] && cp "$f" "$BACKUP_DIR/" || echo "    ⚠️  Fichier non trouvé : $f"
done

# 5. Nettoyage
if [ "$RETENTION_DAYS" -gt 0 ]; then
  echo "  • Suppression des backups de plus de $RETENTION_DAYS jours"
  find "$ABS_BACKUP_BASE_DIR" -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
fi

echo "✅ Backup terminé. Dossiers dans $BACKUP_DIR"
