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

# Convertit BACKUP_BASE_DIR en chemin absolu
ABS_BACKUP_BASE_DIR="$(cd "$BACKUP_BASE_DIR" && pwd)"

# Noms des conteneurs Docker (services par défaut LibreChat)
MONGO_CONTAINER="${MONGO_CONTAINER:-chat-mongodb}"
PG_CONTAINER="${PG_CONTAINER:-vectordb}"

# Paramètres PostgreSQL (utilisateur par défaut postgres, sans mot de passe)
PG_USER="${PG_USER:-postgres}"
# On utilise pg_dumpall pour sauvegarder toutes les bases

# Volumes Docker à sauvegarder (modifiez si besoin)
VOLUMES=("librechat_uploads")

# Fichiers de config à copier (dans la racine du projet)
CONFIG_FILES=(".env" "docker-compose.yml")

# Rétention : supprimer les backups de plus de N jours (mettre 0 pour désactiver)
RETENTION_DAYS=30
### FIN DE LA CONFIG ###

TIMESTAMP="$(date +'%Y-%m-%d_%Hh%M')"
BACKUP_DIR="$ABS_BACKUP_BASE_DIR/backup_$TIMESTAMP"

echo "🗃️  Démarrage du backup LibreChat : $TIMESTAMP"

# Création du répertoire de backup
mkdir -p "$BACKUP_DIR"

# 1. Sauvegarde MongoDB (sans authentification)
echo "  • Sauvegarde MongoDB ($MONGO_CONTAINER)…"
docker exec -i "$MONGO_CONTAINER" \
  mongodump --archive --gzip --db LibreChat \
  > "$BACKUP_DIR/mongo_LibreChat_$TIMESTAMP.gz"
 
# 2. Sauvegarde PostgreSQL vectordb (toutes bases)
echo "  • Sauvegarde PostgreSQL ($PG_CONTAINER) – dump de toutes les bases…"
docker exec -i "$PG_CONTAINER" bash -c \
  "pg_dumpall --username=$PG_USER" \
  > "$BACKUP_DIR/postgres_all_$TIMESTAMP.sql"

# 3. Sauvegarde des volumes Docker
for vol in "${VOLUMES[@]}"; do
  echo "  • Sauvegarde volume Docker : $vol"
  docker run --rm \
    -v "$vol":/data \
    -v "$BACKUP_DIR":/backup \
    alpine sh -c "tar czf /backup/vol_${vol}_${TIMESTAMP}.tgz -C /data ."
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
  find "$ABS_BACKUP_BASE_DIR" -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
fi

echo "✅ Backup terminé. Fichiers stockés dans $BACKUP_DIR"
