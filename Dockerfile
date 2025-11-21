# Gunakan image PHP-FPM resmi
FROM php:8.2-fpm

# Install dependencies OS
RUN apt-get update && apt-get install -y \
    nginx unzip git libzip-dev libpng-dev libfreetype6-dev libjpeg62-turbo-dev libicu-dev procps

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install mysqli pdo pdo_mysql zip gd intl bcmath ftp

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy source OJS ke container
COPY . /var/www/html

# Permission folder OJS
RUN mkdir -p files cache public \
    && chmod -R 777 files cache public

# Copy konfigurasi Nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Hapus config.inc.php bawaan
RUN rm -f /var/www/html/config.inc.php

# Expose port 80
EXPOSE 80

# Start script
CMD ["sh", "-c", "\
    echo 'Generating config...' && \
    echo '<?php exit;' > /var/www/html/config.inc.php && \
    echo '[general]' >> /var/www/html/config.inc.php && \
    echo 'app_key = \"\"' >> /var/www/html/config.inc.php && \
    echo 'installed = '\"${OJS_INSTALLED:-Off}\" >> /var/www/html/config.inc.php && \
    echo 'base_url = \"'\"${BASE_URL:-http://localhost}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'session_cookie_name = OJSSID' >> /var/www/html/config.inc.php && \
    echo 'session_lifetime = 30' >> /var/www/html/config.inc.php && \
    echo 'time_zone = \"UTC\"' >> /var/www/html/config.inc.php && \
    echo 'allow_url_fopen = Off' >> /var/www/html/config.inc.php && \
    echo '[database]' >> /var/www/html/config.inc.php && \
    echo 'driver = \"'\"${DB_DRIVER:-mysqli}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'host = \"'\"${DB_HOST:-localhost}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'username = \"'\"${DB_USERNAME:-ojs}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'password = \"'\"${DB_PASSWORD:-ojs}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'name = \"'\"${DB_DATABASE:-ojs}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'port = '\"${DB_PORT:-3306}\" >> /var/www/html/config.inc.php && \
    echo '[cache]' >> /var/www/html/config.inc.php && \
    echo 'default = file' >> /var/www/html/config.inc.php && \
    echo '[i18n]' >> /var/www/html/config.inc.php && \
    echo 'locale = en' >> /var/www/html/config.inc.php && \
    echo 'connection_charset = utf8' >> /var/www/html/config.inc.php && \
    echo '[files]' >> /var/www/html/config.inc.php && \
    echo 'files_dir = \"'\"${OJS_FILES_DIR:-/var/www/html/files}\"'\"' >> /var/www/html/config.inc.php && \
    echo 'public_files_dir = \"public\"' >> /var/www/html/config.inc.php && \
    echo '[security]' >> /var/www/html/config.inc.php && \
    echo 'force_ssl = Off' >> /var/www/html/config.inc.php && \
    echo 'salt = \"'\"${OJS_SALT:-defaultsalt123}\"'\"' >> /var/www/html/config.inc.php && \
    echo '[email]' >> /var/www/html/config.inc.php && \
    echo 'default = sendmail' >> /var/www/html/config.inc.php && \
    echo '[search]' >> /var/www/html/config.inc.php && \
    echo 'driver = database' >> /var/www/html/config.inc.php && \
    echo '[queues]' >> /var/www/html/config.inc.php && \
    echo 'default_connection = \"database\"' >> /var/www/html/config.inc.php && \
    echo 'job_runner = On' >> /var/www/html/config.inc.php && \
    echo '[schedule]' >> /var/www/html/config.inc.php && \
    echo 'task_runner = On' >> /var/www/html/config.inc.php && \
    chown -R www-data:www-data /var/www/html/files /var/www/html/cache /var/www/html/public && \
    php-fpm -F & nginx -g 'daemon off;'"]
