FROM python:3.9-alpine as back_end

LABEL maintainer="Specify Collections Consortium <github.com/specify>"

RUN apk add --no-cache mysql-client

RUN addgroup -S specify -g 1001 && adduser -S specify -G specify -u 1001
USER specify

ARG LINK
ARG WORKING_LOCATION
ARG MYSQL_HOST
ARG MYSQL_USER
ARG MYSQL_PASSWORD

WORKDIR /home/specify

COPY requirements.txt .
RUN python3 -m venv venv \
  && venv/bin/pip install --no-cache-dir -r requirements.txt

COPY --chown=specify:specify taxa_tree_gbif taxa_tree_gbif
COPY --chown=specify:specify taxa_tree_itis taxa_tree_itis
COPY --chown=specify:specify taxa_tree_col taxa_tree_col
COPY --chown=specify:specify taxa_tree_stats taxa_tree_stats

RUN echo -e \
  "site_link = 'http://nginx/gbif/'" \
  "\ntarget_dir = '/home/specify/taxa_tree_gbif_working_dir/'" \
  "\nmysql_host = 'database'" \
  "\nmysql_user = 'root'" \
  "\nmysql_password = 'root'" \
  >taxa_tree_gbif/back_end/config.py

RUN echo -e \
  "<?php" \
  "\ndefine('DEVELOPMENT', FALSE);" \
  "\ndefine('LINK', '${LINK}gbif/');" \
  "\ndefine('WORKING_LOCATION','/var/www/taxa_tree_gbif_working_dir/');" \
  "\ndefine('STATS_URL', 'http://nginx/stats/collect/');" \
  >taxa_tree_gbif/front_end/config/required.php

RUN echo -e \
  "site_link = 'http://nginx/itis/'" \
  "\ntarget_dir = '/home/specify/taxa_tree_itis_working_dir/'" \
  "\nmysql_host = 'database'" \
  "\nmysql_user = 'root'" \
  "\nmysql_password = 'root'" \
  >taxa_tree_itis/back_end/config.py

RUN echo -e \
  "<?php" \
  "\ndefine('DEVELOPMENT', FALSE);" \
  "\ndefine('LINK', '${LINK}itis/');" \
  "\ndefine('WORKING_LOCATION','/var/www/taxa_tree_itis_working_dir/');" \
  "\ndefine('STATS_URL', 'http://nginx/stats/collect/');" \
  >taxa_tree_itis/front_end/config/required.php

RUN echo -e \
  "<?php" \
  "\ndefine('DEVELOPMENT', FALSE);" \
  "\ndefine('LINK', '${LINK}col/');" \
  "\ndefine('WORKING_LOCATION','/var/www/taxa_tree_col_working_dir/');" \
  "\ndefine('STATS_URL', 'http://nginx/stats/collect/');" \
  >taxa_tree_col/front_end/config/required.php

RUN echo -e \
  "site_link = 'http://nginx/col/'" \
  "\ntarget_dir = '/home/specify/taxa_tree_col_working_dir/'" \
  "\nmysql_host = 'database'" \
  "\nmysql_user = 'root'" \
  "\nmysql_password = 'root'" \
  "\ndocker_container = ''" \
  "\nmysql_command = 'mysql'" \
  "\ndocker_dir = target_dir" \
  >taxa_tree_col/back_end/config.py

RUN echo -e \
  "<?php" \
  "\ndefine('DEVELOPMENT', FALSE);" \
  "\ndefine('LINK', '${LINK}stats/');" \
  "\ndefine('WORKING_LOCATION','/var/www/taxa_tree_stats_working_dir/');" \
  >taxa_tree_stats/config/required.php

COPY --chown=specify:specify docker-entrypoint.sh .
COPY --chown=specify:specify update-taxa.sh .

RUN mkdir \
  taxa_tree_gbif_working_dir \
  taxa_tree_itis_working_dir \
  taxa_tree_col_working_dir \
  taxa_tree_stats_working_dir \
  && chmod -R 777 \
    taxa_tree_gbif_working_dir \
    taxa_tree_itis_working_dir \
    taxa_tree_col_working_dir \
    taxa_tree_stats_working_dir

ENTRYPOINT ["./docker-entrypoint.sh"]

FROM php:7.4-fpm-alpine3.13 as front_end

LABEL maintainer="Specify Collections Consortium <github.com/specify>"

# Install zip PHP module
RUN apk add --no-cache libzip-dev \
  && docker-php-ext-install zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo -e \
  "\n\nmemory_limit = -1" \
  "\nmax_execution_time = 3600" \
  "\nbuffer-size=65535" \
  "\noutput_buffering=65535" \
  >>"$PHP_INI_DIR/php.ini"

RUN addgroup -S specify -g 1001 && adduser -S specify -G specify -u 1001
USER specify

WORKDIR /var/www/
CMD ["php-fpm"]
