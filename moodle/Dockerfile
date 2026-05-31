FROM moodlehq/moodle-php-apache:8.2

ARG MOODLE_VERSION=v4.5.1
ARG MOODLE_DIR=/var/www/html

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${MOODLE_VERSION} \
    https://github.com/moodle/moodle.git ${MOODLE_DIR} \
    && chown -R www-data:www-data ${MOODLE_DIR}

RUN mkdir -p /var/moodledata \
    && chown -R www-data:www-data /var/moodledata \
    && chmod 777 /var/moodledata

VOLUME ["/var/moodledata"]

EXPOSE 80
