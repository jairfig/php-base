#!/usr/bin/env sh
set -e

cd /var/www/html

echo "➡️  Iniciando entrypoint do Laravel…"

# 1) Composer install (somente se 'vendor' estiver ausente)
if [ ! -d "vendor" ]; then
  echo "📦 Instalando dependências PHP (composer install)…"
  export COMPOSER_MEMORY_LIMIT=-1
  composer install --no-interaction --prefer-dist --no-progress
fi

# 2) Garante .env
if [ ! -f ".env" ]; then
  echo "🧪 Criando .env a partir de .env.example (se existir)…"
  if [ -f ".env.example" ]; then
    cp .env.example .env
  else
    touch .env
  fi
fi

# 3) Preenche/atualiza chaves no .env a partir das variáveis de ambiente
set_env() {
  KEY="$1"
  VALUE="$2"
  if [ -n "$VALUE" ]; then
    if grep -q "^$KEY=" .env; then
      sed -i "s|^$KEY=.*|$KEY=${VALUE}|g" .env
    else
      echo "$KEY=${VALUE}" >> .env
    fi
  fi
}

set_env "APP_ENV"     "${APP_ENV:-local}"
set_env "APP_DEBUG"   "${APP_DEBUG:-true}"
set_env "APP_URL"     "${APP_URL:-http://localhost:8000}"

set_env "DB_CONNECTION" "${DB_CONNECTION:-mysql}"
set_env "DB_HOST"       "${DB_HOST:-db}"
set_env "DB_PORT"       "${DB_PORT:-3306}"
set_env "DB_DATABASE"   "${DB_DATABASE:-laravel}"
set_env "DB_USERNAME"   "${DB_USERNAME:-laravel}"
set_env "DB_PASSWORD"   "${DB_PASSWORD:-secret}"

# 4) Gera APP_KEY, se necessário
if ! grep -q "^APP_KEY=base64" .env; then
  echo "🔑 Gerando APP_KEY…"
  php artisan key:generate --force || true
fi

# 5) Aguarda o banco ficar disponível (tentando conectar via PDO)
echo "⏳ Aguardando MySQL em ${DB_HOST:-db}:${DB_PORT:-3306}…"
TRIES=0
until php -r '
$h=getenv("DB_HOST")?: "db";
$P=getenv("DB_PORT")?: "3306";
$d=getenv("DB_DATABASE")?: "laravel";
$u=getenv("DB_USERNAME")?: "laravel";
$p=getenv("DB_PASSWORD")?: "secret";
try {
  new PDO("mysql:host=$h;port=$P;dbname=$d;charset=utf8mb4",$u,$p,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  echo "OK";
} catch (Throwable $e) { http_response_code(1); }' >/dev/null 2>&1
do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -gt 60 ]; then
    echo "❌ Timeout aguardando MySQL."
    break
  fi
  sleep 2
done

# 6) Permissões
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

# 7) Migrations (não aborta se falhar)
echo "🗃️  Rodando migrations…"
php artisan migrate --force || true

# 8) Cache (opcional; não aborta se falhar)
php artisan config:cache  || true
php artisan route:cache   || true

echo "🚀 Iniciando servidor Laravel…"
exec "$@"