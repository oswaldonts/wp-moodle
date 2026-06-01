FROM moodlehq/moodle-php-apache:8.2

ARG MOODLE_VERSION=v4.5.1
ARG MOODLE_DIR=/var/www/html

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# PHP settings required by Moodle
RUN echo "max_input_vars = 5000\nmemory_limit = 256M\nupload_max_filesize = 100M\npost_max_size = 100M" \
    > /usr/local/etc/php/conf.d/moodle.ini

RUN git clone --depth 1 --branch ${MOODLE_VERSION} \
    https://github.com/moodle/moodle.git ${MOODLE_DIR} \
    && chown -R www-data:www-data ${MOODLE_DIR}

# Stage Edwiser Bridge in /opt — entrypoint copies to auth/ after install
RUN curl -fsSL "https://moodle.org/plugins/download.php/41815/auth_edwiserbridge_moodle52_2026051400.zip" \
    -o /tmp/edwiserbridge.zip \
    && unzip /tmp/edwiserbridge.zip -d /opt/edwiserbridge_staging \
    && rm /tmp/edwiserbridge.zip

RUN mkdir -p /var/moodledata \
    && chown -R www-data:www-data /var/moodledata \
    && chmod 777 /var/moodledata

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/moodledata"]

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
