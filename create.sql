CREATE TABLE "public"."pedidos" (
  "id" SERIAL PRIMARY KEY,
  "Orden" INTEGER,
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
	"Fecha entrega" DATE,
  "Actor" TEXT,
  "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "public"."plantas" (
  "id" SERIAL PRIMARY KEY,
  "Planta" TEXT NOT NULL,
  "Tipo" TEXT,
  "Contenedor" TEXT,
  "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "public"."plantas_en_desarrollo";

CREATE TABLE "public"."plantas_en_desarrollo" (
  "id" SERIAL PRIMARY KEY,
  "Estado vivero" TEXT,
  "Cantidad" INTEGER NOT NULL DEFAULT 0,
  "Fecha transplante" DATE NOT NULL,
  "Fecha de entrega" DATE NOT NULL,
  "Planta" INTEGER,
  "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  constraint fk_planta foreign key("Planta") references plantas(id)
);

CREATE TABLE "public"."detalle_pedidos" (
  "id" SERIAL PRIMARY KEY,
  "Cantidad" INTEGER,
  "Planta" INTEGER,
  "Pedido" INTEGER,
  "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  constraint fk_detalle_pedidos_orden foreign key("Pedido") references pedidos(id),
  constraint fk_detalle_pedidos_planta foreign key("Planta") references plantas(id)
);

---
CREATE VIEW unidades_listas_para_entrega AS (
	SELECT
		p. "Planta",
		p. "Tipo",
		p. "Contenedor",
		SUM(
			CASE WHEN ped. "Estado vivero" = 'Lista para entrega' THEN
				CASE WHEN ped. "Fecha de entrega" < CURRENT_DATE THEN
					ped. "Cantidad"
				ELSE
					0
				END
			ELSE
				0
			END) AS "Unidades listas para entrega"
	FROM
		plantas p
	FULL JOIN plantas_en_desarrollo ped ON p.id = ped. "Planta"
GROUP BY
	(p. "Planta",
		p. "Tipo",
		p. "Contenedor")
ORDER BY
	p. "Planta"
);

---
CREATE VIEW unidades_entregadas AS (
	SELECT
		pl. "Planta",
		pl. "Tipo",
		pl. "Contenedor",
		SUM(
			CASE WHEN dp. "Cantidad" IS NOT NULL THEN
				dp. "Cantidad"
			ELSE
				0
			END) AS "Unidades entregadas"
	FROM
		plantas pl
	FULL JOIN detalle_pedidos dp ON pl.id = dp. "Planta"
	FULL JOIN pedidos p ON dp. "Pedido" = p.id
GROUP BY
	(pl. "Planta",
		pl. "Tipo",
		pl. "Contenedor")
ORDER BY
	pl. "Planta"
);

--

SELECT
	ue. "Planta",
	ue. "Tipo",
	ue. "Contenedor",
	ul. "Unidades listas para entrega",
	ue. "Unidades entregadas",
	(ul. "Unidades listas para entrega" - ue. "Unidades entregadas") "Inventario"
FROM
	unidades_entregadas ue
	JOIN unidades_listas_para_entrega ul ON (ue. "Planta" = ul. "Planta"
			OR ue. "Planta" IS NULL
			AND ul. "Planta" IS NULL)
		AND(ue. "Tipo" = ul. "Tipo"
			OR ue. "Tipo" IS NULL
			AND ul. "Tipo" IS NULL)
		AND(ue. "Contenedor" = ul. "Contenedor"
			OR ue. "Contenedor" IS NULL
			AND ul. "Contenedor" IS NULL);