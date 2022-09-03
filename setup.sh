#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DROP DATABASE IF EXISTS "sd_denuncias";

    CREATE DATABASE "sd_denuncias";

    \c sd_denuncias

    DROP TABLE IF EXISTS "public"."denuncias";

    CREATE TABLE "public"."denuncias" (
        "id" SERIAL PRIMARY KEY,
        "created_at" TIMESTAMP DEFAULT now(),
        "updated_at" TIMESTAMP DEFAULT now(),
        "Tipo de denunciante" TEXT,
        "Nombres y Apellidos" TEXT,
        "CI / RUC" TEXT,
        "Razon social" TEXT,
        "Email" TEXT,
        "Telefono" TEXT,
        "Tipo de denuncia" TEXT,
        "Estado de la denuncia" TEXT,
        "Fecha de denuncia" TEXT,
        "Iniciales funcionario receptor" TEXT,
        "Fecha del incidente" TEXT,
        "Componente afectado" TEXT,
        "Canton" TEXT,
        "Parroquia" TEXT,
        "Sector" TEXT,
        "Direccion" TEXT,
        "Tipo de denunciado" TEXT,
        "Nombre del denunciado" TEXT,
        "Descripcion del acto que se denuncia" TEXT,
        "Ubicacion" TEXT
    );
EOSQL
