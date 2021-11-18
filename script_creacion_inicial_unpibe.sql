USE GD2C2021
IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'los_desnormalizados'))
  BEGIN
      exec ('CREATE SCHEMA [los_desnormalizados]');
   END

CREATE TABLE los_desnormalizados.Chofer (
	legajo	INT PRIMARY KEY,
	nombre NVARCHAR(255)	NOT NULL,
	apellido NVARCHAR(255)	NOT NULL,
	dni DECIMAL(18,0)		NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT			NOT NULL,
	mail NVARCHAR(255)		NOT NULL,
	fecha_nac DATETIME2(3)	NOT NULL,
	costo_hora INT			NOT NULL,
)

CREATE TABLE los_desnormalizados.Ciudad (
	ciudad_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Recorrido (
	recorrido_id INT IDENTITY(1,1) PRIMARY KEY,
	ciudad_origen_id INT	NOT NULL,
	ciudad_destino_id INT	NOT NULL,
	km_recorridos INT		NOT NULL,
	precio DECIMAL(18,2)	NOT NULL,
	FOREIGN KEY (ciudad_destino_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id),
	FOREIGN KEY (ciudad_destino_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id)
)

CREATE TABLE los_desnormalizados.Tipo_paquete (
	tipo_paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	paquete_descripcion NVARCHAR(255)	NOT NULL,
	paquete_largo_max DECIMAL(18,2)		NOT NULL,
	paquete_peso_max DECIMAL(18,2)		NOT NULL,
	paquete_ancho_max DECIMAL(18,2)		NOT NULL,
	paquete_precio DECIMAL(18,2)		NOT NULL,
	paquete_alto_max DECIMAL(18,2)		NOT NULL
)

CREATE TABLE los_desnormalizados.Marca (
	marca_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Modelo(
	modelo_id INT IDENTITY(1,1) PRIMARY KEY,
	marca_id INT NOT NULL,
	modelo_descripcion NVARCHAR(255) NOT NULL,
	velocidad_max INT NOT NULL,
	capacidad_tanque INT NOT NULL,
	capacidad_carga INT NOT NULL,
	FOREIGN KEY (marca_id) REFERENCES los_desnormalizados.Marca (marca_id)
)

CREATE TABLE los_desnormalizados.Taller(
	taller_id INT IDENTITY(1,1) PRIMARY KEY, 
	ciudad_id INT NOT NULL,
	nombre NVARCHAR(255) NOT NULL,
	telefono DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	FOREIGN KEY (ciudad_id) REFERENCES los_desnormalizados.Ciudad (ciudad_id)
)

CREATE TABLE  los_desnormalizados.Material (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
	material_cod NVARCHAR(100) NOT NULL,
    material_descripcion NVARCHAR(255) NOT NULL,
    precio DECIMAL(18, 2) NOT NULL,
)

CREATE TABLE los_desnormalizados.Tipo_tarea (
	tipo_tarea_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

CREATE TABLE  los_desnormalizados.Tarea (
    tarea_id INT PRIMARY KEY,
    tipo_tarea_id INT NOT NULL,
    tiempo_estimado INT NOT NULL, 
    descripcion NVARCHAR(255) NOT NULL,
	FOREIGN KEY (tipo_tarea_id) REFERENCES los_desnormalizados.Tipo_tarea (tipo_tarea_id)
)

CREATE TABLE los_desnormalizados.Camion(
	camion_id INT IDENTITY(1,1) PRIMARY KEY, 
	modelo_id INT NOT NULL,
	patente NVARCHAR(255) NOT NULL,
	chasis NVARCHAR(255) NOT NULL,
	motor NVARCHAR(255) NOT NULL,
	fecha_alta DATETIME2(3) NOT NULL,
	FOREIGN KEY (modelo_id) REFERENCES los_desnormalizados.Modelo (modelo_id)
)

CREATE TABLE los_desnormalizados.Viaje (
	viaje_id INT IDENTITY(1,1) PRIMARY KEY,
	camion_id INT NOT NULL,
	recorrido_id INT NOT NULL,
	chofer INT NOT NULL,
	fecha_inicio DATETIME2(7) NOT NULL,
	fecha_fin DATETIME2(3) NULL,
	lts_combustible DECIMAL(18,2) NULL, 
	FOREIGN KEY (camion_id)	REFERENCES los_desnormalizados.Camion (camion_id),
	FOREIGN KEY (chofer)	REFERENCES los_desnormalizados.Chofer (legajo),
	FOREIGN KEY (recorrido_id) REFERENCES los_desnormalizados.Recorrido (recorrido_id)
)

CREATE TABLE los_desnormalizados.Paquete (
	paquete_id INT IDENTITY(1,1) PRIMARY KEY,
	tipo_paquete_id INT NOT NULL,
	FOREIGN KEY (tipo_paquete_id) REFERENCES los_desnormalizados.Tipo_paquete(tipo_paquete_id)
)

CREATE TABLE los_desnormalizados.Viaje_x_paquete (
	paquete_id INT NOT NULL,
	viaje_id INT NOT NULL,
	cantidad INT NOT NULL,
	precioTotal FLOAT NOT NULL,
	PRIMARY KEY (paquete_id, viaje_id),
	FOREIGN KEY (paquete_id) REFERENCES los_desnormalizados.Paquete(paquete_id),
	FOREIGN KEY (viaje_id) REFERENCES los_desnormalizados.Viaje(viaje_id)
)

CREATE TABLE los_desnormalizados.Estado (
	estado_id INT IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(255) NOT NULL,
)

CREATE TABLE los_desnormalizados.Orden_trabajo (
	orden_id INT IDENTITY(1,1) PRIMARY KEY,
	fecha_generacion NVARCHAR(255) NOT NULL,
	camion_id INT NOT NULL,
	estado_id INT NOT NULL,
	FOREIGN KEY (camion_id) REFERENCES los_desnormalizados.Camion(camion_id),
	FOREIGN KEY (estado_id) REFERENCES los_desnormalizados.Estado(estado_id)
)

CREATE TABLE los_desnormalizados.Mecanico(
	legajo INT PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL,
	apellido NVARCHAR(255) NOT NULL,
	dni DECIMAL(18,0) NOT NULL,
	direccion NVARCHAR(255) NOT NULL,
	telefono INT NOT NULL,
	mail NVARCHAR(255) NOT NULL,
	fecha_nacimiento DATETIME2(3) NOT NULL,
	costo_hora INT NOT NULL,
	taller_id INT NOT NULL,
	FOREIGN KEY (taller_id) REFERENCES los_desnormalizados.Taller (taller_id)
)

CREATE TABLE los_desnormalizados.Tarea_x_orden(
	tarea_x_orden_id INT IDENTITY(1,1) PRIMARY KEY,
    orden_id INT NOT NULL,
    tarea_id INT NOT NULL,
    mecanico_id INT NOT NULL,
    inicio_planificado DATETIME2 NOT NULL,
    inicio_real DATETIME2 NULL,
    fin_real DATETIME2 NULL,
	tiempo_real INT NULL,
    FOREIGN KEY (tarea_id) references los_desnormalizados.Tarea (tarea_id),
    FOREIGN KEY (mecanico_id) references los_desnormalizados.Mecanico (legajo),
    FOREIGN KEY (orden_id) references  los_desnormalizados.Orden_trabajo (orden_id)
)

CREATE TABLE  los_desnormalizados.Material_x_tarea(
    material_id INT NOT NULL,
    tarea_id INT NOT NULL, 
	cant_material INT NOT NULL,
	PRIMARY KEY (material_id, tarea_id),
    FOREIGN KEY (material_id) REFERENCES  los_desnormalizados.Material (material_id),
    FOREIGN KEY (tarea_id) REFERENCES  los_desnormalizados.Tarea (tarea_id)
)

-- Chofer
INSERT INTO los_desnormalizados.Chofer (legajo, nombre, apellido, dni, direccion, telefono, mail, fecha_nac, costo_hora)
	SELECT DISTINCT CHOFER_NRO_LEGAJO, CHOFER_NOMBRE, CHOFER_APELLIDO, CHOFER_DNI, CHOFER_DIRECCION, CHOFER_TELEFONO, 
	CHOFER_MAIL, CHOFER_FECHA_NAC, CHOFER_COSTO_HORA FROM gd_esquema.Maestra
	WHERE CHOFER_NRO_LEGAJO IS NOT NULL

-- Ciudad
INSERT INTO los_desnormalizados.Ciudad (nombre)
	SELECT DISTINCT RECORRIDO_CIUDAD_DESTINO FROM gd_esquema.Maestra
		WHERE RECORRIDO_CIUDAD_DESTINO IS NOT NULL
	UNION
	SELECT DISTINCT RECORRIDO_CIUDAD_ORIGEN FROM gd_esquema.Maestra
		WHERE RECORRIDO_CIUDAD_ORIGEN IS NOT NULL
	UNION
	SELECT DISTINCT TALLER_CIUDAD FROM gd_esquema.Maestra
		WHERE TALLER_CIUDAD IS NOT NULL
		
-- Recorrido
INSERT INTO los_desnormalizados.Recorrido (ciudad_origen_id, ciudad_destino_id, km_recorridos,
		precio)
	SELECT DISTINCT c1.ciudad_id, c2.ciudad_id, RECORRIDO_KM, RECORRIDO_PRECIO FROM gd_esquema.Maestra m
		JOIN los_desnormalizados.Ciudad c1 ON (c1.nombre = m.RECORRIDO_CIUDAD_ORIGEN)
		JOIN los_desnormalizados.Ciudad c2 ON (c2.nombre = m.RECORRIDO_CIUDAD_DESTINO)
	WHERE RECORRIDO_KM IS NOT NULL


-- Tipo Paquete
INSERT INTO los_desnormalizados.Tipo_paquete (paquete_descripcion, paquete_largo_max,
		paquete_peso_max, paquete_ancho_max, paquete_precio, paquete_alto_max)
	SELECT DISTINCT PAQUETE_DESCRIPCION, PAQUETE_LARGO_MAX, PAQUETE_PESO_MAX, PAQUETE_ANCHO_MAX, 
		PAQUETE_PRECIO, PAQUETE_ALTO_MAX FROM gd_esquema.Maestra
	WHERE PAQUETE_DESCRIPCION IS NOT NULL

-- Marca
INSERT INTO los_desnormalizados.Marca (nombre)
	SELECT DISTINCT MARCA_CAMION_MARCA FROM gd_esquema.Maestra
	WHERE MARCA_CAMION_MARCA IS NOT NULL

-- Modelo
INSERT INTO los_desnormalizados.Modelo (marca_id, modelo_descripcion, velocidad_max, capacidad_tanque, capacidad_carga)
	SELECT DISTINCT marca.marca_id, MODELO_CAMION, MODELO_VELOCIDAD_MAX, MODELO_CAPACIDAD_TANQUE, 
	MODELO_CAPACIDAD_CARGA FROM gd_esquema.Maestra maestra
		JOIN los_desnormalizados.Marca marca ON (marca.nombre = maestra.MARCA_CAMION_MARCA)
	WHERE MODELO_CAMION IS NOT NULL

-- Taller
INSERT INTO los_desnormalizados.Taller (ciudad_id, nombre, telefono, direccion, mail)
	SELECT DISTINCT c.ciudad_id, TALLER_NOMBRE, TALLER_TELEFONO, TALLER_DIRECCION, 
	TALLER_MAIL
	FROM gd_esquema.Maestra m
		JOIN los_desnormalizados.Ciudad c on (c.nombre = m.TALLER_CIUDAD)
	WHERE TALLER_NOMBRE IS NOT NULL

-- Material
INSERT INTO los_desnormalizados.Material (material_cod, material_descripcion, precio)
	SELECT DISTINCT MATERIAL_COD, MATERIAL_DESCRIPCION, MATERIAL_PRECIO FROM gd_esquema.Maestra
	WHERE MATERIAL_COD IS NOT NULL

-- Tipo_tarea
INSERT INTO los_desnormalizados.Tipo_tarea (descripcion)
	SELECT DISTINCT TIPO_TAREA FROM gd_esquema.Maestra
	WHERE TIPO_TAREA IS NOT NULL

-- Tarea:
INSERT INTO los_desnormalizados.Tarea (tarea_id, tipo_tarea_id, tiempo_estimado, descripcion)
	SELECT DISTINCT TAREA_CODIGO, tt.tipo_tarea_id, TAREA_TIEMPO_ESTIMADO, TAREA_DESCRIPCION
	FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Tipo_tarea tt ON (tt.descripcion = m.TIPO_TAREA)
	WHERE TAREA_CODIGO IS NOT NULL


-- Camion
INSERT INTO los_desnormalizados.Camion (modelo_id, patente, chasis, motor, fecha_alta)
	SELECT DISTINCT modelo.modelo_id, CAMION_PATENTE, CAMION_NRO_CHASIS,
	CAMION_NRO_MOTOR, CAMION_FECHA_ALTA FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Modelo modelo ON (modelo.modelo_descripcion = m.MODELO_CAMION
		AND modelo.velocidad_max = m.MODELO_VELOCIDAD_MAX AND modelo.capacidad_tanque = m.MODELO_CAPACIDAD_TANQUE
		 AND modelo.capacidad_carga = m.MODELO_CAPACIDAD_CARGA)
	JOIN los_desnormalizados.Marca marca ON (marca.nombre = m.MARCA_CAMION_MARCA)
	WHERE CAMION_PATENTE IS NOT NULL
	ORDER BY CAMION_PATENTE

-- Viaje
INSERT INTO los_desnormalizados.Viaje (camion_id, recorrido_id, chofer, fecha_inicio,
	fecha_fin, lts_combustible)
	SELECT DISTINCT c.camion_id, r.recorrido_id, ch.legajo, VIAJE_FECHA_INICIO, 
		VIAJE_FECHA_FIN, VIAJE_CONSUMO_COMBUSTIBLE FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Camion c ON (m.CAMION_PATENTE = c.patente)
	JOIN los_desnormalizados.Ciudad c1 ON (c1.nombre = m.RECORRIDO_CIUDAD_ORIGEN)
	JOIN los_desnormalizados.Ciudad c2 ON (c2.nombre = m.RECORRIDO_CIUDAD_DESTINO)
	JOIN los_desnormalizados.Recorrido r ON (c1.ciudad_id = r.ciudad_origen_id AND
		c2.ciudad_id = r.ciudad_destino_id)
	JOIN los_desnormalizados.Chofer ch ON (ch.legajo = m.CHOFER_NRO_LEGAJO)
	WHERE VIAJE_FECHA_INICIO IS NOT NULL


-- Paquete
INSERT INTO los_desnormalizados.Paquete (tipo_paquete_id)
	SELECT tipo_paquete_id FROM los_desnormalizados.Tipo_paquete

-- Viaje_x_paquete
INSERT INTO los_desnormalizados.Viaje_x_paquete (paquete_id, viaje_id, cantidad, precioTotal)
	SELECT DISTINCT paquete_id, viaje_id, SUM(PAQUETE_CANTIDAD), SUM(PAQUETE_CANTIDAD) * tp.paquete_precio + r.precio
	FROM gd_esquema.Maestra m
		JOIN los_desnormalizados.Camion c ON (m.CAMION_PATENTE = c.patente)
		JOIN los_desnormalizados.Viaje v ON (v.fecha_inicio = m.VIAJE_FECHA_INICIO AND
			v.camion_id = c.camion_id)
		JOIN los_desnormalizados.Tipo_paquete tp ON (tp.paquete_descripcion = m.PAQUETE_DESCRIPCION)
		JOIN los_desnormalizados.Paquete p ON (p.tipo_paquete_id = tp.tipo_paquete_id)
		JOIN los_desnormalizados.Recorrido r ON (r.recorrido_id = v.recorrido_id)
		group by viaje_id, paquete_id, tp.paquete_precio, r.precio

-- Estado
INSERT INTO los_desnormalizados.Estado (descripcion)
	SELECT DISTINCT ORDEN_TRABAJO_ESTADO FROM gd_esquema.Maestra
	WHERE ORDEN_TRABAJO_ESTADO IS NOT NULL

-- Oden_trabajo
INSERT INTO los_desnormalizados.Orden_trabajo (fecha_generacion, camion_id, estado_id)
	SELECT DISTINCT ORDEN_TRABAJO_FECHA, camion_id, estado_id FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Camion c ON (c.patente = m.CAMION_PATENTE)
	JOIN los_desnormalizados.Estado e ON (e.descripcion = m.ORDEN_TRABAJO_ESTADO)

--Mecanico
INSERT INTO los_desnormalizados.Mecanico (legajo, nombre, apellido, dni, direccion, telefono, mail, 
	fecha_nacimiento, costo_hora, taller_id)
	SELECT DISTINCT MECANICO_NRO_LEGAJO, MECANICO_NOMBRE, MECANICO_APELLIDO, MECANICO_DNI,
		MECANICO_DIRECCION, MECANICO_TELEFONO, MECANICO_MAIL, MECANICO_FECHA_NAC, MECANICO_COSTO_HORA,
		t.taller_id FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.taller t ON (t.nombre = TALLER_NOMBRE)
	WHERE MECANICO_NRO_LEGAJO IS NOT NULL

-- Tarea_x_orden.
INSERT INTO los_desnormalizados.Tarea_x_orden (orden_id, tarea_id, mecanico_id, inicio_planificado, inicio_real,
		fin_real, tiempo_real)
	SELECT DISTINCT orden_id, tarea_id, legajo, TAREA_FECHA_INICIO_PLANIFICADO, TAREA_FECHA_INICIO, TAREA_FECHA_FIN, 
	DATEDIFF(day, TAREA_FECHA_INICIO, TAREA_FECHA_FIN)
	FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Camion c ON (c.patente = m.CAMION_PATENTE)
	JOIN los_desnormalizados.Orden_trabajo ot ON (ot.fecha_generacion = m.ORDEN_TRABAJO_FECHA AND 
		ot.camion_id = c.camion_id)
	JOIN los_desnormalizados.Tarea t ON (t.tarea_id = m.TAREA_CODIGO)
	JOIN los_desnormalizados.Mecanico mec ON (mec.legajo = m.MECANICO_NRO_LEGAJO)


-- Material_x_tarea
INSERT INTO los_desnormalizados.Material_x_tarea (material_id, tarea_id, cant_material)
	SELECT DISTINCT material_id, 
					tarea_id, 
					COUNT(m.MATERIAL_COD) / (select count(distinct convert(varchar,TAREA_FECHA_FIN)
                            +convert(varchar, TAREA_FECHA_INICIO)
                            +convert(varchar, TAREA_FECHA_INICIO_PLANIFICADO)
                            +str(TAREA_TIEMPO_ESTIMADO)+ CAMION_PATENTE)
					FROM gd_esquema.Maestra
					WHERE TAREA_CODIGO= m.TAREA_CODIGO)
	FROM gd_esquema.Maestra m
	JOIN los_desnormalizados.Material mate ON (m.MATERIAL_DESCRIPCION = mate.material_descripcion)
	JOIN los_desnormalizados.Tarea t ON (t.tarea_id = m.TAREA_CODIGO) 
    GROUP BY TAREA_CODIGO, m.MATERIAL_COD, m.MATERIAL_DESCRIPCION, material_id, tarea_id