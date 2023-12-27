FROM debian:11

# Instalação do Debian e atualizações
RUN apt-get update
RUN apt-get upgrade -y

# Instalação de facilitadores
RUN apt-get -y install locate mlocate wget apt-utils curl apt-transport-https lsb-release \
    ca-certificates software-properties-common zip unzip vim rpl apt-utils

# Correção do 'add-apt-repository command not found'
RUN apt-get install software-properties-common

# Instalação do PHP-FPM
RUN apt-get update && apt-get install -y \
    php7.4-fpm

RUN apt-get install -y php7.4-mysqlnd

# Instalação do modulo LDAP
RUN apt-get install -y php7.4-ldap

#PHP Install PDO MySQL
RUN apt-get -y install php7.4-pdo php7.4-pdo-mysql php7.4-mysql

#Driver sqlite
RUN apt-get -y install php7.4-sqlite3

# Instalação do PHPUnit
RUN wget -O /usr/local/bin/phpunit-9.phar https://phar.phpunit.de/phpunit-9.0.phar; \
    chmod +x /usr/local/bin/phpunit-9.phar; \
    ln -s /usr/local/bin/phpunit-9.phar /usr/local/bin/phpunit

## Configuração personalizada do PHP para Adianti
# Set PHP custom settings
RUN echo "\n# Custom settings"                                    >> /etc/php/7.4/fpm/php.ini \
    && echo "memory_limit = 256M"                                 >> /etc/php/7.4/fpm/php.ini \
    && echo "max_execution_time = 120"                            >> /etc/php/7.4/fpm/php.ini \
    && echo "file_uploads = On"                                   >> /etc/php/7.4/fpm/php.ini \
    && echo "post_max_size = 100M"                                >> /etc/php/7.4/fpm/php.ini \
    && echo "upload_max_filesize = 100M"                          >> /etc/php/7.4/fpm/php.ini \
    && echo "session.gc_maxlifetime = 14000"                      >> /etc/php/7.4/fpm/php.ini \
    && echo "display_errors = On"                                 >> /etc/php/7.4/fpm/php.ini \
    && echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT" >> /etc/php/7.4/fpm/php.ini

# Set PHP security settings
RUN echo "\n# Security settings"                    >> /etc/php/7.4/fpm/php.ini \
    && echo "session.name = CUSTOMSESSID"           >> /etc/php/7.4/fpm/php.ini \
    && echo "session.use_only_cookies = 1"          >> /etc/php/7.4/fpm/php.ini \
    && echo "session.cookie_httponly = true"        >> /etc/php/7.4/fpm/php.ini \
    && echo "session.use_trans_sid = 0"             >> /etc/php/7.4/fpm/php.ini \
    && echo "session.entropy_file = /dev/urandom"   >> /etc/php/7.4/fpm/php.ini \
    && echo "session.entropy_length = 32"           >> /etc/php/7.4/fpm/php.ini

## Instalação de pré-requisitos para o Drive SQL Server
RUN apt-get -y install php7.4-dev php7.4-xml php7.4-intl unixodbc-dev

# Definição da variável de ambiente ACCEPT_EULA
ENV ACCEPT_EULA=Y

# Configuração da chave GPG e lista de fontes para o repositório Microsoft SQL Server
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -s https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update

# Instalação de pacotes adicionais
RUN apt-get install -y --no-install-recommends \
    locales \
    apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

## Instalação do Drive 5.9.0 para SQL Server
RUN pecl install sqlsrv-5.9.0
RUN pecl install pdo_sqlsrv-5.9.0

# Configuração para PHP CLI
RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

# Configuração para PHP WEB
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.4/fpm/conf.d/30-pdo_sqlsrv.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.4/fpm/conf.d/20-sqlsrv.ini

# Instalação do Nginx
RUN apt-get update && apt-get install -y \
    nginx

# Configuração do nginx.conf
RUN echo "user www-data;" > /etc/nginx/nginx.conf \
    && echo "worker_processes 1;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "events {" >> /etc/nginx/nginx.conf \
    && echo "    worker_connections 1024;" >> /etc/nginx/nginx.conf \
    && echo "}" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "http {" >> /etc/nginx/nginx.conf \
    && echo "    include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf \
    && echo "    default_type application/octet-stream;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "    sendfile on;" >> /etc/nginx/nginx.conf \
    && echo "    keepalive_timeout 65;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "    server {" >> /etc/nginx/nginx.conf \
    && echo "       listen 880 default_server;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "       root /var/www/html;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "       index index.php index.html index.htm index.nginx-debian.html;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "       server_name _;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "       location / {" >> /etc/nginx/nginx.conf \
    && echo "           try_files \$uri \$uri/ =404;" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "           rewrite ^/auth$ /rest.php?class=ApplicationAuthenticationRestService&method=getToken last;" >> /etc/nginx/nginx.conf \
    && echo "           rewrite ^/api/([\w]+)/([\w]+)$ /rest.php?class=$1RestService&method=handle&id=$2&$args last;" >> /etc/nginx/nginx.conf \
    && echo "           rewrite ^/api/([\w]+)/([\w]+)/([\w]+)$ /rest.php?class=$1RestService&method=$3&id=$2&$args last;" >> /etc/nginx/nginx.conf \
    && echo "           rewrite ^/api/([\w]+)$ /rest.php?class=$1RestService&method=handle&$args last;" >> /etc/nginx/nginx.conf \
    && echo "       }" >> /etc/nginx/nginx.conf \
    && echo "" >> /etc/nginx/nginx.conf \
    && echo "       location ~ \.php$ {" >> /etc/nginx/nginx.conf \
    && echo "           include snippets/fastcgi-php.conf;" >> /etc/nginx/nginx.conf \
    && echo "           fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;" >> /etc/nginx/nginx.conf \
    && echo "       }" >> /etc/nginx/nginx.conf \
    && echo "   }" >> /etc/nginx/nginx.conf \
    && echo "}" >> /etc/nginx/nginx.conf

# Exporta a porta 880 para o Nginx
EXPOSE 880

# Inicialização dos serviços
CMD service php7.4-fpm start && nginx -g "daemon off;"
