USE [GD2C2021]
GO


/*****************************************
 *          CREACION DE SCHEMA           *
 *****************************************/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'GRAN_EXCEL')
BEGIN
    EXEC ('CREATE SCHEMA GRAN_EXCEL')
END
GO


/*****************************************
 *            DROP DE TABLAS             *
 *****************************************/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.MaterialesXTareas'))
BEGIN
	ALTER TABLE GRAN_EXCEL.MaterialesXTareas DROP CONSTRAINT matxtar_id_tarea;
	ALTER TABLE GRAN_EXCEL.MaterialesXTareas DROP CONSTRAINT matxtar_id_material;
	DROP TABLE GRAN_EXCEL.MaterialesXTareas
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.TareasXOrdenes'))
BEGIN
	ALTER TABLE GRAN_EXCEL.TareasXOrdenes DROP CONSTRAINT tarxord_id_tarea;
	ALTER TABLE GRAN_EXCEL.TareasXOrdenes DROP CONSTRAINT tarxord_id_orden;
	ALTER TABLE GRAN_EXCEL.TareasXOrdenes DROP CONSTRAINT tarxord_legajo_mecanico;
	DROP TABLE GRAN_EXCEL.TareasXOrdenes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Tareas'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Tareas DROP CONSTRAINT tareas_id_tipo_tarea;
	DROP TABLE GRAN_EXCEL.Tareas
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Tipos_tareas'))
BEGIN
	DROP TABLE GRAN_EXCEL.Tipos_tareas
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.PaquetesXViajes'))
BEGIN
	ALTER TABLE GRAN_EXCEL.PaquetesXViajes DROP CONSTRAINT paqxviaj_id_paquete;
	ALTER TABLE GRAN_EXCEL.PaquetesXViajes DROP CONSTRAINT paqxviaj_id_viaje;
	DROP TABLE GRAN_EXCEL.PaquetesXViajes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Paquetes'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Paquetes DROP CONSTRAINT paquetes_id_viaje;
	ALTER TABLE GRAN_EXCEL.Paquetes DROP CONSTRAINT paquetes_id_tipo;
	DROP TABLE GRAN_EXCEL.Paquetes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Tipos_paquetes'))
BEGIN
	DROP TABLE GRAN_EXCEL.Tipos_paquetes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Ordenes'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Ordenes DROP CONSTRAINT ordenes_id_camion;
	ALTER TABLE GRAN_EXCEL.Ordenes DROP CONSTRAINT ordenes_id_trabajo_estado;
	DROP TABLE GRAN_EXCEL.Ordenes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Estados_trabajo'))
BEGIN
	DROP TABLE GRAN_EXCEL.Estados_trabajo
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Viajes'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Viajes DROP CONSTRAINT viajes_id_camion_designado;
	ALTER TABLE GRAN_EXCEL.Viajes DROP CONSTRAINT viajes_id_chofer_designado;
	ALTER TABLE GRAN_EXCEL.Viajes DROP CONSTRAINT viajes_id_recorrido;
	DROP TABLE GRAN_EXCEL.Viajes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Choferes'))
BEGIN
	DROP TABLE GRAN_EXCEL.Choferes
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Recorridos'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Recorridos DROP CONSTRAINT recorridos_id_ciudad_origen;
	ALTER TABLE GRAN_EXCEL.Recorridos DROP CONSTRAINT recorridos_id_ciudad_destino;
	DROP TABLE GRAN_EXCEL.Recorridos
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Camiones'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Camiones DROP CONSTRAINT camiones_id_modelo;
	DROP TABLE GRAN_EXCEL.Camiones
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Modelos'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Modelos DROP CONSTRAINT modelos_id_marca;
	DROP TABLE GRAN_EXCEL.Modelos
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Marcas'))
BEGIN
	DROP TABLE GRAN_EXCEL.Marcas
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Mecanicos'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Mecanicos DROP CONSTRAINT mecanicos_id_taller;
	DROP TABLE GRAN_EXCEL.Mecanicos
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Talleres'))
BEGIN
	ALTER TABLE GRAN_EXCEL.Talleres DROP CONSTRAINT talleres_id_ciudad;
	DROP TABLE GRAN_EXCEL.Talleres
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Ciudades'))
BEGIN
	DROP TABLE GRAN_EXCEL.Ciudades
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'GRAN_EXCEL.Materiales'))
BEGIN
	DROP TABLE GRAN_EXCEL.Materiales
END



/*****************************************
 *          DROP DE FUNCIONES            *
 *****************************************/



/*****************************************
 *          DROP DE PROCEDURES           *
 *****************************************/
 
IF (OBJECT_ID('GRAN_EXCEL.sp_migrate_data') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_migrate_data
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_materiales') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_materiales
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_ciudades') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_ciudades
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_talleres') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_talleres
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_mecanicos') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_mecanicos
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_marcas') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_marcas
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_modelos') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_modelos
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_camiones') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_camiones
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_recorridos') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_recorridos
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_choferes') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_choferes
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_viajes') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_viajes
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_estados_trabajo') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_estados_trabajo
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_ordenes') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_ordenes
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_tipos_paquetes') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_tipos_paquetes
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_paquetes_x_viaje') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_paquetes_x_viaje
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_tipos_tareas') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_tipos_tareas
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_tareas') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_tareas
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_tareas_x_ordenes') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_tareas_x_ordenes
GO

IF (OBJECT_ID('GRAN_EXCEL.sp_carga_materiales_x_tarea') IS NOT NULL)
	DROP PROCEDURE GRAN_EXCEL.sp_carga_materiales_x_tarea
GO


/*****************************************
 *          CREACION DE TABLAS           *
 *****************************************/

CREATE TABLE [GRAN_EXCEL].[Materiales] (
    [id_material] INT IDENTITY(1,1),
    [descripcion] NVARCHAR(255) NOT NULL,
	[codigo] NVARCHAR(100) NOT NULL,
    [precio] DECIMAL(18,2) NOT NULL,	
    PRIMARY KEY (id_material)
)

CREATE TABLE [GRAN_EXCEL].[Ciudades] (
	[id_ciudad] INT IDENTITY(1,1),
	[nombre] NVARCHAR(255) UNIQUE NOT NULL,
	PRIMARY KEY(id_ciudad)
)

CREATE TABLE [GRAN_EXCEL].[Talleres] (
	[id_taller] INT IDENTITY,
	[direccion] NVARCHAR(255) NOT NULL,
	[telefono] DECIMAL(18, 0) NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
	[nombre] NVARCHAR(255) NOT NULL,
	[id_ciudad] INT NOT NULL,
	PRIMARY KEY(id_taller)
)
ALTER TABLE [GRAN_EXCEL].[Talleres] ADD CONSTRAINT talleres_id_ciudad FOREIGN KEY (id_ciudad) REFERENCES [GRAN_EXCEL].[Ciudades](id_ciudad)

CREATE TABLE [GRAN_EXCEL].[Mecanicos] (
	[nro_legajo] INT IDENTITY,
	[dni] DECIMAL(18, 0) UNIQUE NOT NULL,
	[id_taller] INT NOT NULL,
	[nombre] NVARCHAR(255) NOT NULL,
	[apellido] NVARCHAR(255) NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[telefono] INT NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
	[fecha_nacimiento] DATETIME2(3) NOT NULL,
	[costo_hora] INT NOT NULL,
	PRIMARY KEY(nro_legajo)
)
ALTER TABLE [GRAN_EXCEL].[Mecanicos] ADD CONSTRAINT mecanicos_id_taller FOREIGN KEY (id_taller) REFERENCES [GRAN_EXCEL].[Talleres](id_taller)

CREATE TABLE [GRAN_EXCEL].[Marcas] (
	[id_marca] INT IDENTITY(1,1),
	[descripcion] NVARCHAR(50) NOT NULL,
	PRIMARY KEY(id_marca)
)

CREATE TABLE [GRAN_EXCEL].[Modelos] (
	[id_modelo] INT IDENTITY(1,1),
	[camion] NVARCHAR(255) NOT NULL,
	[velocidad_max] INT NOT NULL,
	[capacidad_tanque] INT NOT NULL,
	[capacidad_carga] INT NOT NULL,
	[id_marca] INT NOT NULL,
	PRIMARY KEY(id_modelo)
)
ALTER TABLE [GRAN_EXCEL].[Modelos] ADD CONSTRAINT modelos_id_marca FOREIGN KEY (id_marca) REFERENCES [GRAN_EXCEL].[Marcas](id_marca)


CREATE TABLE [GRAN_EXCEL].[Camiones] (
	[id_camion] INT IDENTITY(1,1),
	[patente] NVARCHAR(255) NOT NULL,
	[nro_chasis] NVARCHAR(255) NOT NULL,
	[nro_motor] NVARCHAR(255) NOT NULL,
	[id_modelo] INT NOT NULL,
	[fecha_alta] DATETIME2(3) NOT NULL,
	PRIMARY KEY(id_camion)
)
ALTER TABLE [GRAN_EXCEL].[Camiones] ADD CONSTRAINT camiones_id_modelo FOREIGN KEY (id_modelo) REFERENCES [GRAN_EXCEL].[Modelos](id_modelo)


CREATE TABLE [GRAN_EXCEL].[Recorridos] (
	[id_recorrido] INT IDENTITY(1,1),
	[id_ciudad_origen] INT NOT NULL,
	[id_ciudad_destino] INT NOT NULL,
	[km] INT NOT NULL,
	[precio] DECIMAL(18,2) NOT NULL,
	PRIMARY KEY(id_recorrido)
)
ALTER TABLE [GRAN_EXCEL].[Recorridos] ADD CONSTRAINT recorridos_id_ciudad_origen FOREIGN KEY (id_ciudad_origen) REFERENCES [GRAN_EXCEL].[Ciudades](id_ciudad)
ALTER TABLE [GRAN_EXCEL].[Recorridos] ADD CONSTRAINT recorridos_id_ciudad_destino FOREIGN KEY (id_ciudad_destino) REFERENCES [GRAN_EXCEL].[Ciudades](id_ciudad)



CREATE TABLE [GRAN_EXCEL].[Choferes] (
	[nro_legajo] INT IDENTITY,
	[dni] DECIMAL(18, 0) NOT NULL,
	[nombre] NVARCHAR(255) NOT NULL,
	[apellido] NVARCHAR(255) NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[telefono] INT NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
	[fecha_nacimiento] DATETIME2(3) NOT NULL,
	[costo_hora] INT NOT NULL,	
	PRIMARY KEY(nro_legajo)
)

CREATE TABLE [GRAN_EXCEL].[Viajes] (
	[id_viaje] INT IDENTITY(1,1),
	[id_camion_designado] INT NOT NULL,
	[legajo_chofer_designado] INT NOT NULL,
	[id_recorrido] INT NOT NULL,
	[fecha_inicio] DATETIME2(3),
	[fecha_fin] DATETIME2(3),
	[consumo_combustible] DECIMAL(18,2) NOT NULL,	
	PRIMARY KEY(id_viaje)
)
ALTER TABLE [GRAN_EXCEL].[Viajes] ADD CONSTRAINT viajes_id_camion_designado FOREIGN KEY (id_camion_designado) REFERENCES [GRAN_EXCEL].[Camiones](id_camion)
ALTER TABLE [GRAN_EXCEL].[Viajes] ADD CONSTRAINT viajes_id_chofer_designado FOREIGN KEY (legajo_chofer_designado) REFERENCES [GRAN_EXCEL].[Choferes](nro_legajo)
ALTER TABLE [GRAN_EXCEL].[Viajes] ADD CONSTRAINT viajes_id_recorrido FOREIGN KEY (id_recorrido) REFERENCES [GRAN_EXCEL].[Recorridos](id_recorrido)


CREATE TABLE [GRAN_EXCEL].[Estados_trabajo] (
	[id_estado] INT IDENTITY(1,1),
	[descripcion] NVARCHAR(255) NOT NULL,
	PRIMARY KEY(id_estado)
)

CREATE TABLE [GRAN_EXCEL].[Ordenes] (
	[nro_trabajo] INT IDENTITY(1,1),
	[id_camion] INT NOT NULL,
	[trabajo_fecha] DATETIME2(3) NOT NULL,
	[id_trabajo_estado] INT,
	PRIMARY KEY(nro_trabajo)
)
ALTER TABLE [GRAN_EXCEL].[Ordenes] ADD CONSTRAINT ordenes_id_camion FOREIGN KEY (id_camion) REFERENCES [GRAN_EXCEL].[Camiones](id_camion)
ALTER TABLE [GRAN_EXCEL].[Ordenes] ADD CONSTRAINT ordenes_id_trabajo_estado FOREIGN KEY (id_trabajo_estado) REFERENCES [GRAN_EXCEL].[Estados_trabajo](id_estado)

CREATE TABLE [GRAN_EXCEL].[Tipos_paquetes] (
	[id_tipo] INT IDENTITY(1,1),
	[descripcion] NVARCHAR(255) NOT NULL,
	[peso_max] DECIMAL(18, 2) NOT NULL,
	[alto_max] DECIMAL(18, 2) NOT NULL,
	[ancho_max] DECIMAL(18, 2) NOT NULL,
	[largo_max] DECIMAL(18, 2) NOT NULL,
	[precio] DECIMAL(18, 2) NOT NULL,
	PRIMARY KEY(id_tipo)
)

/*-CREATE TABLE [GRAN_EXCEL].[Paquetes] (
	[id_paquete] INT IDENTITY(1,1),
	[id_viaje] INT NOT NULL,
	[cantidad] INT NOT NULL,
	[id_tipo] INT NOT NULL,
	PRIMARY KEY(id_paquete)
)
ALTER TABLE [GRAN_EXCEL].[Paquetes] ADD CONSTRAINT paquetes_id_viaje FOREIGN KEY (id_viaje) REFERENCES [GRAN_EXCEL].[Viajes](id_viaje)
ALTER TABLE [GRAN_EXCEL].[Paquetes] ADD CONSTRAINT paquetes_id_tipo FOREIGN KEY (id_tipo) REFERENCES [GRAN_EXCEL].[Tipos_paquetes](id_tipo)
*/

CREATE TABLE [GRAN_EXCEL].[Paquetes] (
	[id_paquete] INT IDENTITY(1,1) PRIMARY KEY,
	[id_tipo] INT NOT NULL,
	FOREIGN KEY ([id_tipo]) REFERENCES [GRAN_EXCEL].[Tipos_paquetes]([id_tipo])
)


CREATE TABLE [GRAN_EXCEL].[PaquetesXViajes] (
	[id_paquetes_x_viaje] INT IDENTITY(1,1),
	[id_tipo_paquete] INT NOT NULL,
	[id_viaje] INT NOT NULL,
	[cantidad] INT NOT NULL,
	PRIMARY KEY(id_paquetes_x_viaje)
)
ALTER TABLE [GRAN_EXCEL].[PaquetesXViajes] ADD CONSTRAINT paqxviaj_id_paquete FOREIGN KEY (id_tipo_paquete) REFERENCES [GRAN_EXCEL].[Tipos_paquetes](id_tipo)
ALTER TABLE [GRAN_EXCEL].[PaquetesXViajes] ADD CONSTRAINT paqxviaj_id_viaje FOREIGN KEY (id_viaje) REFERENCES [GRAN_EXCEL].[Viajes](id_viaje)


CREATE TABLE [GRAN_EXCEL].[Tipos_tareas] (
	[id_tipo_tarea] INT IDENTITY(1,1),
	[descripcion] NVARCHAR(255) UNIQUE NOT NULL,
	PRIMARY KEY(id_tipo_tarea)
)

CREATE TABLE [GRAN_EXCEL].[Tareas] (
	[codigo] INT IDENTITY,
	[id_tipo_tarea] INT NOT NULL,
	[tiempo_estimado] INT NOT NULL,
	[descripcion] NVARCHAR(255) NOT NULL,
	PRIMARY KEY(codigo)
)
ALTER TABLE [GRAN_EXCEL].[Tareas] ADD CONSTRAINT tareas_id_tipo_tarea FOREIGN KEY (id_tipo_tarea) REFERENCES [GRAN_EXCEL].[Tipos_tareas](id_tipo_tarea)

CREATE TABLE [GRAN_EXCEL].[TareasXOrdenes] (
	[id_tareas_x_ordenes] INT IDENTITY(1,1),
	[fecha_inicio_planificado] DATETIME2(3) NOT NULL,
	[fecha_inicio] DATETIME2(3) NOT NULL,
	[fecha_fin] DATETIME2(3) NOT NULL,
	[tiempo_real_dias] INT NOT NULL,
	[id_orden] INT NOT NULL,
	[id_tarea] INT NOT NULL,
	[legajo_mecanico] INT NOT NULL,
	PRIMARY KEY(id_tareas_x_ordenes)
)
ALTER TABLE [GRAN_EXCEL].[TareasXOrdenes] ADD CONSTRAINT tarxord_id_tarea FOREIGN KEY (id_tarea) REFERENCES [GRAN_EXCEL].[Tareas](codigo)
ALTER TABLE [GRAN_EXCEL].[TareasXOrdenes] ADD CONSTRAINT tarxord_id_orden FOREIGN KEY (id_orden) REFERENCES [GRAN_EXCEL].[Ordenes](nro_trabajo)
ALTER TABLE [GRAN_EXCEL].[TareasXOrdenes] ADD CONSTRAINT tarxord_legajo_mecanico FOREIGN KEY (legajo_mecanico) REFERENCES [GRAN_EXCEL].[Mecanicos](nro_legajo)

CREATE TABLE [GRAN_EXCEL].[MaterialesXTareas] (
	[id_materiales_x_tareas] INT IDENTITY(1,1),
	[id_material] INT NOT NULL,
	[id_tarea] INT NOT NULL,
	[cantidad] INT NOT NULL,
	PRIMARY KEY(id_materiales_x_tareas)
)
ALTER TABLE [GRAN_EXCEL].[MaterialesXTareas] ADD CONSTRAINT matxtar_id_tarea FOREIGN KEY (id_tarea) REFERENCES [GRAN_EXCEL].[Tareas](codigo)
ALTER TABLE [GRAN_EXCEL].[MaterialesXTareas] ADD CONSTRAINT matxtar_id_material FOREIGN KEY (id_material) REFERENCES [GRAN_EXCEL].[Materiales](id_material)


GO

/**********************************
 *           FUNCTIONS            *
 **********************************/



/*****************************************
 *           STORE PROCEDURES            *
 *****************************************/

CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_materiales]
AS
    INSERT INTO [GRAN_EXCEL].[Materiales](codigo, descripcion, precio)
	SELECT DISTINCT m.[MATERIAL_COD], m.[MATERIAL_DESCRIPCION], m.[MATERIAL_PRECIO]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[MATERIAL_DESCRIPCION] IS NOT NULL
	  AND m.[MATERIAL_COD] IS NOT NULL
	  AND m.[MATERIAL_PRECIO] IS NOT NULL
GO




CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_ciudades]
AS
    INSERT INTO [GRAN_EXCEL].[Ciudades](nombre)
	SELECT DISTINCT m.[TALLER_CIUDAD]
	FROM [GRAN_EXCEL].[Ciudades] c
    RIGHT JOIN [gd_esquema].[Maestra] m ON c.nombre = m.TALLER_CIUDAD
	WHERE m.[TALLER_CIUDAD] IS NOT NULL
	  AND c.[nombre] IS NULL

    INSERT INTO [GRAN_EXCEL].[Ciudades](nombre)
	SELECT DISTINCT m.[RECORRIDO_CIUDAD_ORIGEN]
	FROM [GRAN_EXCEL].[Ciudades] c
    RIGHT JOIN [gd_esquema].[Maestra] m ON c.nombre = m.RECORRIDO_CIUDAD_ORIGEN
	WHERE m.[RECORRIDO_CIUDAD_ORIGEN] IS NOT NULL
	  AND c.[nombre] IS NULL
	  
	  INSERT INTO [GRAN_EXCEL].[Ciudades](nombre)
	SELECT DISTINCT m.[RECORRIDO_CIUDAD_DESTINO]
	FROM [GRAN_EXCEL].[Ciudades] c
    RIGHT JOIN [gd_esquema].[Maestra] m ON c.nombre = m.RECORRIDO_CIUDAD_DESTINO
	WHERE m.[RECORRIDO_CIUDAD_DESTINO] IS NOT NULL
	  AND c.[nombre] IS NULL
	  
GO



CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_talleres]
AS
    INSERT INTO [GRAN_EXCEL].[Talleres](nombre, direccion, telefono, mail, id_ciudad)
	SELECT DISTINCT m.[TALLER_NOMBRE], m.[TALLER_DIRECCION], m.[TALLER_TELEFONO], m.[TALLER_MAIL], c.id_ciudad
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Ciudades] c
	WHERE m.[TALLER_NOMBRE] IS NOT NULL
	  AND m.[TALLER_DIRECCION] IS NOT NULL
	  AND m.[TALLER_TELEFONO] IS NOT NULL
	  AND m.[TALLER_MAIL] IS NOT NULL
	  AND c.nombre = m.[TALLER_CIUDAD]
GO



CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_mecanicos]
AS
	SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Mecanicos] ON
	
    INSERT INTO [GRAN_EXCEL].[Mecanicos](nro_legajo, dni, id_taller, nombre, apellido, direccion, telefono, mail, fecha_nacimiento, costo_hora)
	SELECT DISTINCT m.[MECANICO_NRO_LEGAJO], m.[MECANICO_DNI], t.id_taller, m.[MECANICO_NOMBRE], m.[MECANICO_APELLIDO], m.[MECANICO_DIRECCION], m.[MECANICO_TELEFONO], m.[MECANICO_MAIL], m.[MECANICO_FECHA_NAC],  m.[MECANICO_COSTO_HORA]
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Talleres] t
	WHERE m.[MECANICO_NRO_LEGAJO] IS NOT NULL
	  AND m.[MECANICO_DNI] IS NOT NULL
	  AND m.[MECANICO_NOMBRE] IS NOT NULL
	  AND m.[MECANICO_APELLIDO] IS NOT NULL
	  AND m.[MECANICO_DIRECCION] IS NOT NULL
	  AND m.[MECANICO_TELEFONO] IS NOT NULL
	  AND m.[MECANICO_MAIL] IS NOT NULL
	  AND m.[MECANICO_FECHA_NAC] IS NOT NULL
	  AND m.[MECANICO_COSTO_HORA] IS NOT NULL
	  AND t.nombre = m.[TALLER_NOMBRE]
	  
	  SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Mecanicos] OFF
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_marcas]
AS
    INSERT INTO [GRAN_EXCEL].[Marcas](descripcion)
	SELECT DISTINCT m.[MARCA_CAMION_MARCA]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[MARCA_CAMION_MARCA] IS NOT NULL
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_modelos]
AS
    INSERT INTO [GRAN_EXCEL].[Modelos](camion, velocidad_max, capacidad_tanque, capacidad_carga, id_marca)
	SELECT DISTINCT m.[MODELO_CAMION], m.[MODELO_VELOCIDAD_MAX], m.[MODELO_CAPACIDAD_TANQUE], m.[MODELO_CAPACIDAD_CARGA], mar.id_marca
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Marcas] mar
	WHERE m.[MODELO_CAMION] IS NOT NULL
	AND m.[MODELO_VELOCIDAD_MAX] IS NOT NULL
	AND m.[MODELO_CAPACIDAD_TANQUE] IS NOT NULL
	AND m.[MODELO_CAPACIDAD_CARGA] IS NOT NULL
	AND mar.descripcion = m.[MARCA_CAMION_MARCA]
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_camiones]
AS
    INSERT INTO [GRAN_EXCEL].[Camiones](patente, nro_chasis, nro_motor, id_modelo, fecha_alta)
	SELECT DISTINCT m.[CAMION_PATENTE], m.[CAMION_NRO_CHASIS], m.[CAMION_NRO_MOTOR], mo.id_modelo, m.[CAMION_FECHA_ALTA]
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Modelos] mo
	WHERE m.[CAMION_PATENTE] IS NOT NULL
	AND m.[CAMION_NRO_CHASIS] IS NOT NULL
	AND m.[CAMION_NRO_MOTOR] IS NOT NULL
	AND m.[CAMION_FECHA_ALTA] IS NOT NULL
	AND mo.camion = m.[MODELO_CAMION]
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_recorridos]
AS
    INSERT INTO [GRAN_EXCEL].[Recorridos](km, precio, id_ciudad_origen, id_ciudad_destino)
	SELECT DISTINCT m.[RECORRIDO_KM], m.[RECORRIDO_PRECIO], c.id_ciudad, c2.id_ciudad
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Ciudades] c, [GRAN_EXCEL].[Ciudades] c2
	WHERE m.[RECORRIDO_KM] IS NOT NULL
	AND m.[RECORRIDO_PRECIO] IS NOT NULL
	AND c.nombre = m.[RECORRIDO_CIUDAD_ORIGEN]
	AND c2.nombre = m.[RECORRIDO_CIUDAD_DESTINO]
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_choferes]
AS
	SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Choferes] ON
	
    INSERT INTO [GRAN_EXCEL].[Choferes](nro_legajo, dni, nombre, apellido, direccion, telefono, mail, fecha_nacimiento, costo_hora)
	SELECT DISTINCT m.[CHOFER_NRO_LEGAJO], m.[CHOFER_DNI], m.[CHOFER_NOMBRE], m.[CHOFER_APELLIDO], m.[CHOFER_DIRECCION], m.[CHOFER_TELEFONO], m.[CHOFER_MAIL], m.[CHOFER_FECHA_NAC], m.[CHOFER_COSTO_HORA]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[CHOFER_NRO_LEGAJO] IS NOT NULL
	AND m.[CHOFER_DNI] IS NOT NULL
	AND m.[CHOFER_NOMBRE] IS NOT NULL
	AND m.[CHOFER_APELLIDO] IS NOT NULL
	AND m.[CHOFER_DIRECCION] IS NOT NULL
	AND m.[CHOFER_TELEFONO] IS NOT NULL
	AND m.[CHOFER_MAIL] IS NOT NULL
	AND m.[CHOFER_FECHA_NAC] IS NOT NULL
	AND m.[CHOFER_COSTO_HORA] IS NOT NULL
	
	SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Choferes] OFF
GO


	 
CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_viajes]
AS

/*
VIEJO
    INSERT INTO [GRAN_EXCEL].[Viajes](fecha_inicio, fecha_fin, consumo_combustible, id_camion_designado, legajo_chofer_designado, id_recorrido)
	SELECT m.[VIAJE_FECHA_INICIO], m.[VIAJE_FECHA_FIN], m.[VIAJE_CONSUMO_COMBUSTIBLE], cam.id_camion, cho.nro_legajo, r.id_recorrido
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Camiones] cam, [GRAN_EXCEL].[Choferes] cho, [GRAN_EXCEL].[Recorridos] r, [GRAN_EXCEL].[Ciudades] c, [GRAN_EXCEL].[Ciudades] c2
	WHERE m.[VIAJE_FECHA_INICIO] IS NOT NULL
	AND m.[VIAJE_FECHA_FIN] IS NOT NULL
	AND m.[VIAJE_CONSUMO_COMBUSTIBLE] IS NOT NULL
	AND cam.patente = m.[CAMION_PATENTE]
	AND cho.nro_legajo = m.[CHOFER_NRO_LEGAJO]
	AND c.nombre = m.[RECORRIDO_CIUDAD_ORIGEN]
	AND c2.nombre = m.[RECORRIDO_CIUDAD_DESTINO]
	AND r.km = m.[RECORRIDO_KM]
	AND r.precio = m.[RECORRIDO_PRECIO]
	*/
    INSERT INTO [GRAN_EXCEL].[Viajes](fecha_inicio, fecha_fin, consumo_combustible, id_camion_designado, legajo_chofer_designado, id_recorrido)
	SELECT DISTINCT c.id_camion_designado, r.id_recorrido, ch.legajo_chofer_designado, fecha_inicio, fecha_fin, consumo_combustible
	FROM [gd_esquema].[Maestra] m
	JOIN [GRAN_EXCEL].[Camiones] c ON (m.[CAMION_PATENTE] = c.patente)
	JOIN [GRAN_EXCEL].[Ciudades] c1 ON (c1_[nombre] = m.[RECORRIDO_CIUDAD_ORIGEN])
	JOIN [GRAN_EXCEL].[Ciudades] c2 ON (c2.[nombre] = m.[RECORRIDO_CIUDAD_DESTINO])
	JOIN [GRAN_EXCEL].[Recorridos] r ON (c1.[id_ciudad] = r.[id_ciudad_origen] AND c2.[id_ciudad] = r.[id_ciudad_destino])
	JOIN [GRAN_EXCEL].[Choferes] ch ON (ch.[nro_legajo] = m.[CHOFER_NRO_LEGAJO])
	WHERE [VIAJE_FECHA_INICIO] IS NOT NULL

GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_estados_trabajo]
AS
	
    INSERT INTO [GRAN_EXCEL].[Estados_trabajo](descripcion)
	SELECT DISTINCT m.[ORDEN_TRABAJO_ESTADO]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[ORDEN_TRABAJO_ESTADO] IS NOT NULL
	
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_ordenes]
AS
    INSERT INTO [GRAN_EXCEL].[Ordenes](trabajo_fecha, id_camion, id_trabajo_estado)
	SELECT DISTINCT m.[ORDEN_TRABAJO_FECHA], c.id_camion, e.id_estado
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Camiones] c, [GRAN_EXCEL].[Estados_trabajo] e
	WHERE m.[ORDEN_TRABAJO_FECHA] IS NOT NULL
	AND c.patente = m.[CAMION_PATENTE]
	AND e.descripcion = m.[ORDEN_TRABAJO_ESTADO]
GO

CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_tipos_paquetes]
AS
    INSERT INTO [GRAN_EXCEL].[Tipos_paquetes](descripcion, peso_max, alto_max, ancho_max, largo_max, precio)
	SELECT DISTINCT m.[PAQUETE_DESCRIPCION], m.[PAQUETE_PESO_MAX], m.[PAQUETE_ALTO_MAX], m.[PAQUETE_ANCHO_MAX], m.[PAQUETE_LARGO_MAX], m.[PAQUETE_PRECIO]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[PAQUETE_DESCRIPCION] IS NOT NULL
	AND m.[PAQUETE_PESO_MAX] IS NOT NULL
	AND m.[PAQUETE_ALTO_MAX] IS NOT NULL
	AND m.[PAQUETE_ANCHO_MAX] IS NOT NULL
	AND m.[PAQUETE_LARGO_MAX] IS NOT NULL
	AND m.[PAQUETE_PRECIO] IS NOT NULL
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_paquetes]
AS
INSERT INTO [GRAN_EXCEL].[Paquetes] ([id_tipo])

	SELECT [id_tipo]
	FROM [GRAN_EXCEL].[Tipos_paquetes]

GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_paquetes_x_viaje]
AS
    INSERT INTO [GRAN_EXCEL].[PaquetesXViajes](cantidad, id_tipo_paquete, id_viaje)
	SELECT SUM(m.[PAQUETE_CANTIDAD]), t.id_tipo, v.id_viaje
	FROM [gd_esquema].[Maestra] m
	join [GRAN_EXCEL].[Camiones] cam on m.[CAMION_PATENTE] = cam.patente
	join [GRAN_EXCEL].[Viajes] v on (v.fecha_inicio = m.[VIAJE_FECHA_INICIO] and v.fecha_fin = m.[VIAJE_FECHA_FIN] and cam.id_camion = v.id_camion_designado and v.legajo_chofer_designado = m.[CHOFER_NRO_LEGAJO])
	join [GRAN_EXCEL].[Tipos_paquetes] t on t.descripcion = m.[PAQUETE_DESCRIPCION]
	WHERE m.[PAQUETE_CANTIDAD] IS NOT NULL
	GROUP BY t.id_tipo, v.id_viaje
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_tipos_tareas]
AS
    INSERT INTO [GRAN_EXCEL].[Tipos_tareas](descripcion)
	SELECT DISTINCT m.[TIPO_TAREA]
	FROM [gd_esquema].[Maestra] m
	WHERE m.[TIPO_TAREA] IS NOT NULL
GO



CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_tareas]
AS
	SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Tareas] ON
	
    INSERT INTO [GRAN_EXCEL].[Tareas](codigo, id_tipo_tarea, tiempo_estimado, descripcion)
	SELECT DISTINCT m.[TAREA_CODIGO], t.id_tipo_tarea, m.[TAREA_TIEMPO_ESTIMADO], m.[TAREA_DESCRIPCION]
	FROM [gd_esquema].[Maestra] m, [GRAN_EXCEL].[Tipos_tareas] t
	WHERE m.[TAREA_CODIGO] IS NOT NULL
	AND m.[TAREA_FECHA_INICIO_PLANIFICADO] IS NOT NULL
	AND m.[TAREA_TIEMPO_ESTIMADO] IS NOT NULL
	AND m.[TAREA_DESCRIPCION] IS NOT NULL	
	AND t.descripcion = m.[TIPO_TAREA]
	
	SET IDENTITY_INSERT [GD2C2021].[GRAN_EXCEL].[Tareas] OFF
GO

CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_tareas_x_ordenes]
AS
    INSERT INTO [GRAN_EXCEL].[TareasXOrdenes](fecha_inicio_planificado, fecha_inicio, fecha_fin, tiempo_real_dias, id_orden, id_tarea, legajo_mecanico)
	select distinct m.[TAREA_FECHA_INICIO_PLANIFICADO], m.[TAREA_FECHA_INICIO], m.[TAREA_FECHA_FIN], DATEDIFF(DAY, m.[TAREA_FECHA_INICIO], m.[TAREA_FECHA_FIN]), o.nro_trabajo, t.codigo, m.[MECANICO_NRO_LEGAJO]
	from [gd_esquema].[Maestra] m
	join [GRAN_EXCEL].Camiones c on m.[CAMION_PATENTE] = patente 
	join [GRAN_EXCEL].Ordenes o on (trabajo_fecha = m.[ORDEN_TRABAJO_FECHA] and o.id_camion = c.id_camion)
	join [GRAN_EXCEL].Tareas t on m.[TAREA_DESCRIPCION] = t.descripcion
	order by m.[MECANICO_NRO_LEGAJO], t.codigo
GO

CREATE PROCEDURE [GRAN_EXCEL].[sp_carga_materiales_x_tarea]
AS
    INSERT INTO [GRAN_EXCEL].[MaterialesXTareas](id_material, id_tarea, cantidad)
	select mat.id_material, t.codigo, COUNT(m2.[MATERIAL_COD]) / (select count(distinct convert(varchar, m.[TAREA_FECHA_FIN])
							+convert(varchar,  m.[TAREA_FECHA_INICIO])
							+convert(varchar,  m.[TAREA_FECHA_INICIO_PLANIFICADO])
							+str( m.[TAREA_TIEMPO_ESTIMADO])+  m.[CAMION_PATENTE])
	from [gd_esquema].[Maestra] m
	WHERE m.[TAREA_CODIGO]= m2.[TAREA_CODIGO] and m.[TAREA_DESCRIPCION] <> 'null')
	from [gd_esquema].[Maestra] m2,  [GRAN_EXCEL].[Materiales] mat,  [GRAN_EXCEL].[Tareas] t
	WHERE m2.[TAREA_DESCRIPCION] IS NOT NULL
	AND mat.codigo = m2.[MATERIAL_COD]
	AND t.codigo = m2.[TAREA_CODIGO]
	group by  mat.id_material, m2.[TAREA_CODIGO], t.codigo
GO


CREATE PROCEDURE [GRAN_EXCEL].[sp_migrate_data]
AS
EXEC [GRAN_EXCEL].[sp_carga_materiales]
EXEC [GRAN_EXCEL].[sp_carga_ciudades]   
EXEC [GRAN_EXCEL].[sp_carga_talleres]  
EXEC [GRAN_EXCEL].[sp_carga_mecanicos]         
EXEC [GRAN_EXCEL].[sp_carga_marcas]
EXEC [GRAN_EXCEL].[sp_carga_modelos]
EXEC [GRAN_EXCEL].[sp_carga_camiones]
EXEC [GRAN_EXCEL].[sp_carga_recorridos]
EXEC [GRAN_EXCEL].[sp_carga_choferes]
EXEC [GRAN_EXCEL].[sp_carga_viajes]
EXEC [GRAN_EXCEL].[sp_carga_estados_trabajo]
EXEC [GRAN_EXCEL].[sp_carga_ordenes]
EXEC [GRAN_EXCEL].[sp_carga_tipos_paquetes]
EXEC [GRAN_EXCEL].[sp_carga_paquetes_x_viaje]
EXEC [GRAN_EXCEL].[sp_carga_tipos_tareas]
EXEC [GRAN_EXCEL].[sp_carga_tareas]
EXEC [GRAN_EXCEL].[sp_carga_tareas_x_ordenes]
EXEC [GRAN_EXCEL].[sp_carga_materiales_x_tarea]
    
GO

EXEC [GRAN_EXCEL].[sp_migrate_data]  
GO