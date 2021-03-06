FROM php:7.2-apache
LABEL maintainer="Lars Sielaff <lars.sielaff@t-online.de>"

# Install TYPO3
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
# Configure PHP
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
# Install required 3rd party tools
        graphicsmagick && \
# Configure extensions
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) mysqli soap gd zip opcache && \
    echo 'always_populate_raw_post_data = -1\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 32M\npost_max_size = 32M' > /usr/local/etc/php/conf.d/typo3.ini && \
# Configure Apache as needed
    a2enmod rewrite && \
    apt-get clean && \
    apt-get -y purge \
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /usr/src/*

RUN cd /var/www/html && \
    wget -O - https://get.typo3.org/8.7 | tar -xzf - && \
    ln -s typo3_src-* typo3_src && \
    ln -s typo3_src/index.php && \
    ln -s typo3_src/typo3 && \
    ln -s typo3_src/_.htaccess .htaccess && \
    mkdir typo3temp && \
    mkdir typo3conf && \
    mkdir fileadmin && \
    mkdir uploads && \
    touch FIRST_INSTALL && \
    chown -R www-data. .

# Configure volumes
VOLUME /var/www/html/fileadmin
VOLUME /var/www/html/typo3conf
VOLUME /var/www/html/typo3temp
VOLUME /var/www/html/uploads
RUN \
apt-get update
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server-10.1 
RUN \
  rm -rf /var/lib/apt/lists/* 
RUN \  
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf 
# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /data
# RUN echo "service apache2 start" >> run.sh
RUN echo "service mysql start" >> run.sh
RUN echo "/usr/sbin/apache2ctl -D FOREGROUNDbash" >> run.sh
RUN chmod 777 run.sh
COPY sql.sh /data/
RUN chmod 777 sql.sh
ENTRYPOINT sh /data/run.sh && sh /data/sql.sh && bash 
# Define default command.

