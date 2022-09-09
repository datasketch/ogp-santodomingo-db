#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DROP TABLE IF EXISTS "sd_denuncias";

    CREATE DATABASE "sd_denuncias";

    \c sd_denuncias

    DROP TABLE IF EXISTS "public"."denuncias";

    CREATE TABLE "public"."denuncias" (
        "id" SERIAL PRIMARY KEY,
        "created_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        "Tipo de denunciante" text,
        "Nombres y Apellidos" text,
        "CI / RUC" text,
        "Razon social" text,
        "Email" text,
        "Telefono" text,
        "Tipo de denuncia" text,
        "Estado de la denuncia" text,
        "Fecha de denuncia" text,
        "Iniciales funcionario receptor" text,
        "Fecha del incidente" text,
        "Componente afectado" text,
        "Canton" text,
        "Parroquia" text,
        "Sector" text,
        "Direccion" text,
        "Tipo de denunciado" text,
        "Nombre del denunciado" text,
        "Descripcion del acto que se denuncia" text,
        "Ubicacion" text
    );

    DROP DATABASE IF EXISTS "sd_plantas";

    CREATE DATABASE "sd_plantas";

    \c sd_plantas

    DROP TABLE IF EXISTS "public"."plantas_en_desarrollo";

    CREATE SEQUENCE IF NOT EXISTS plantas_en_desarrollo_orden_seq;

    CREATE TABLE "public"."plantas" (
        "id" SERIAL primary key,
        "Planta" text not null,
        "Tipo" text,
        "Contenedor" text,
        "created_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ default CURRENT_TIMESTAMP
    );

    CREATE TABLE "public"."plantas_en_desarrollo" (
        "id" SERIAL primary key,
        "Orden" INTEGER not null default nextval('plantas_en_desarrollo_orden_seq'::regclass),
        "Estado vivero" text,
        "Cantidad" INTEGER not null default 0,
        "Fecha transplante" DATE,
        "Fecha de entrega" DATE,
        "Planta" INTEGER,
        "created_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        constraint fk_planta foreign key("Planta") references plantas(id)
    );

    CREATE VIEW ordenes_de_compra AS (
    SELECT
        CONCAT(EXTRACT(YEAR FROM ped."Fecha de entrega"), '-', p."Planta", '-#', ped."Orden") "Ordenes de compra",
        ped."Orden",
        (
            CASE WHEN ped."Fecha de entrega" < CURRENT_DATE THEN
                "Cantidad"
            ELSE
                0
            END) AS "Unidades preparadas",
        ped."Estado vivero",
        p."Planta",
        ped."Cantidad",
        ped."Fecha transplante",
        ped."Fecha de entrega"
    FROM
        plantas_en_desarrollo ped
        JOIN plantas p ON p.id = ped."Planta"
    ORDER BY ped."Orden"
    );

    CREATE VIEW AS inventario (
    SELECT
        p. "Planta",
        p. "Tipo",
        p. "Contenedor",
        SUM(
            CASE WHEN odc. "Estado vivero" = 'Unidades trasplantadas' THEN
                odc. "Unidades preparadas"
            ELSE
                0
            END) AS "Unidades trasplantadas",
        SUM(
            CASE WHEN odc. "Estado vivero" = 'Creciendo' THEN
                odc. "Unidades preparadas"
            ELSE
                0
            END) AS "Unidades creciendo",
        SUM(
            CASE WHEN odc. "Estado vivero" = 'Lista para entrega' THEN
                odc. "Unidades preparadas"
            ELSE
                0
            END) AS "Unidades listas para entrega"
    FROM
        plantas p
        JOIN plantas_en_desarrollo ped ON p.id = ped. "Planta"
        JOIN ordenes_de_compra odc ON ped. "Orden" = odc. "Orden"
    GROUP BY
        (p. "Planta",
            p. "Tipo",
            p. "Contenedor",
            odc. "Orden")
    ORDER BY
        p. "Planta"
    );
EOSQL
