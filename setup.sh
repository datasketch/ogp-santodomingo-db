#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DROP TABLE IF EXISTS "sd_denuncias";

    CREATE DATABASE "sd_denuncias";

    \c sd_denuncias

    DROP TABLE IF EXISTS "public"."denuncias";

    CREATE TABLE "public"."denuncias" (
        "id" SERIAL PRIMARY KEY,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
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
        "Ubicacion" TEXT,
        "Fuente" TEXT,
        "Actividad denunciada" TEXT
    );

    DROP DATABASE IF EXISTS "sd_plantas";

    CREATE DATABASE "sd_plantas";

    \c sd_plantas

    DROP TABLE IF EXISTS "public"."plantas";

    CREATE TABLE "public"."plantas" (
        "id" SERIAL PRIMARY KEY,
        "Planta" TEXT NOT NULL,
        "Tipo" TEXT,
        "Contenedor" TEXT,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS "public"."plantas_en_desarrollo";

    CREATE SEQUENCE IF NOT EXISTS plantas_en_desarrollo_orden_seq;

    CREATE TABLE "public"."plantas_en_desarrollo" (
        "id" SERIAL PRIMARY KEY,
        "Orden" INTEGER NOT NULL DEFAULT nextval('plantas_en_desarrollo_orden_seq'::regclass),
        "Estado vivero" TEXT,
        "Cantidad" INTEGER NOT NULL DEFAULT 0,
        "Fecha transplante" DATE,
        "Fecha de entrega" DATE,
        "Planta" INTEGER,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        constraint fk_planta foreign key("Planta") references plantas(id)
    );

    DROP TABLE IF EXISTS "public"."gestion_pedidos";

    CREATE SEQUENCE IF NOT EXISTS gestion_pedidos_orden_seq;

    CREATE TABLE "public"."gestion_pedidos" (
        "id" SERIAL PRIMARY KEY,
        "Orden" INTEGER NOT NULL NOT NULL DEFAULT nextval('gestion_pedidos_orden_seq'::regclass),
        "Estado" TEXT,
        "Fecha" DATE,
        "Año" INTEGER,
        "Nombre beneficiario" TEXT,
        "Parroquia" TEXT,
        "Cantón" TEXT,
        "Teléfono" TEXT,
        "Dirección / Sector" TEXT,
        "Cédula" TEXT,
        "Subsidio o venta" TEXT,
        "Ubicación" TEXT,
        "Colaboradores" TEXT,
        "Supervivencia individuos" INTEGER,
        "Fecha medición" DATE,
        "Actor" TEXT,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

    DROP TABLE IF EXISTS "public"."detalle_pedidos";

    CREATE TABLE "public"."detalle_pedidos" (
        "id" SERIAL PRIMARY KEY,
        "Cantidad" INTEGER,
        "Orden" INTEGER,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        constraint fk_detalle_pedidos_orden foreign key("Orden") references gestion_pedidos(id)
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

    CREATE VIEW inventario AS (
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
