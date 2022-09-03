FROM postgres:12

COPY ./setup.sh /docker-entrypoint-initdb.d/