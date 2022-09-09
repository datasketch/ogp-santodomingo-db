#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DROP DATABASE IF EXISTS "sd_denuncias";

    create database "sd_denuncias";

    \c sd_denuncias

    drop table if exists "public"."denuncias";

    create table "public"."denuncias" (
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

    drop database if exists "sd_plantas";

    create database "sd_plantas";

    \c sd_plantas

    drop table if exists "public"."plantas_en_desarrollo";

    create sequence if not exists plantas_en_desarrollo_orden_seq;

    create table "public"."plantas" (
        "id" SERIAL primary key,
        "Planta" text not null,
        "Tipo" text,
        "Contenedor" text,
        "created_at" TIMESTAMPTZ default CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMPTZ default CURRENT_TIMESTAMP
    );

    create table "public"."plantas_en_desarrollo" (
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
EOSQL
