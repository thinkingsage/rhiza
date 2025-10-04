#!/bin/bash
# Database backup script

BACKUP_DIR="/Users/stevenm/exarcos/rhiza/data/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="rhiza_backup_${TIMESTAMP}.cypher"

mkdir -p "$BACKUP_DIR"

# Export all data to Cypher format
podman exec rhiza-neo4j-1 cypher-shell -u neo4j -p password "
CALL apoc.export.cypher.all('${BACKUP_FILE}', {
  format: 'cypher-shell',
  useOptimizations: {type: 'UNWIND_BATCH', unwindBatchSize: 20}
})
" > "${BACKUP_DIR}/${BACKUP_FILE}"

echo "Backup created: ${BACKUP_DIR}/${BACKUP_FILE}"

# Keep only last 7 backups
find "$BACKUP_DIR" -name "rhiza_backup_*.cypher" -type f -mtime +7 -delete
