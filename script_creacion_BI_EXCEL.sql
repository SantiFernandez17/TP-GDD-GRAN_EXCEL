--Todas las dimensiones de Microsoft SQL Server Analysis Services son grupos de atributos basados en columnas de tablas o vistas de una vista del origen de datos.


USE GD2C2021

go

IF OBJECT_ID ('GRAN_EXCEL.BI_hecho_arreglo', 'U') IS NOT NULL  
   DROP TABLE GRAN_EXCEL.BI_hecho_arreglo; 
GO
IF OBJECT_ID ('GRAN_EXCEL.BI_hecho_envio', 'U') IS NOT NULL
   DROP TABLE GRAN_EXCEL.BI_hecho_envio; 
GO
--DROP DE FUNCIONES------------------------------------------------------------

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'getAgeRange')
	DROP FUNCTION GRAN_EXCEL.getAgeRange

--DROP DE TABLAS------------------------------------------------------------
IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CAMION')
DROP TABLE GRAN_EXCEL.BI_DIM_CAMION

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TIEMPO')
DROP TABLE GRAN_EXCEL.BI_DIM_TIEMPO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MODELO')
DROP TABLE GRAN_EXCEL.BI_DIM_MODELO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MARCA')
DROP TABLE GRAN_EXCEL.BI_DIM_MARCA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TALLER')
DROP TABLE GRAN_EXCEL.BI_DIM_TALLER

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_RECORRIDO')
DROP TABLE GRAN_EXCEL.BI_DIM_RECORRIDO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TIPO_TAREA')
DROP TABLE GRAN_EXCEL.BI_DIM_TIPO_TAREA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_TAREA')
DROP TABLE GRAN_EXCEL.BI_DIM_TAREA

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CHOFER')
DROP TABLE GRAN_EXCEL.BI_DIM_CHOFER

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MECANICO')
DROP TABLE GRAN_EXCEL.BI_DIM_MECANICO

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MATERIAL')
DROP TABLE GRAN_EXCEL.BI_DIM_MATERIAL

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_VIAJE_X_PAQUETE')
DROP TABLE GRAN_EXCEL.BI_DIM_VIAJE_X_PAQUETE

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_FACT_ARREGLO_CAMION')
DROP TABLE GRAN_EXCEL.BI_FACT_ARREGLO_CAMION

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_FACT_INFO_VIAJE')
DROP TABLE GRAN_EXCEL.BI_FACT_INFO_VIAJE

--CREACIÓN DE FUNCIONES AUXILIARES------------------------------------------------------------
GO
CREATE FUNCTION GRAN_EXCEL.getAgeRange (@dateofbirth datetime2(3)) --Recibe una fecha de nacimiento por parámetro y 
RETURNS varchar(10)												   --devuelve la edad actual de la persona		
AS
BEGIN
	DECLARE @age int;
	DECLARE @returnvalue varchar(10);

IF (MONTH(@dateofbirth)!=MONTH(GETDATE()))
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;
ELSE IF(DAY(@dateofbirth) > DAY(GETDATE()))
	SET @age = (DATEDIFF(MONTH, @dateofbirth, GETDATE())/12)-1;
ELSE 
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;

IF (@age > 17 AND @age <31)
BEGIN
	SET @returnvalue = '[18 - 30]';
END
ELSE IF (@age > 30 AND @age < 51)
BEGIN
	SET @returnvalue = '[31 - 50]';
END
ELSE IF(@age > 50)
BEGIN
	SET @returnvalue = '+50';
END

	RETURN @returnvalue;
END

GO

--Creación y migración de las tablas de las dimensiones


--DIMENSION TIEMPO 
CREATE TABLE GRAN_EXCEL.BI_DIM_TIEMPO(
	tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
	anio SMALLDATETIME,
	cuatrimestre INT 
)

--DE DONDE SACAMOS LA FECHA?
INSERT INTO GRAN_EXCEL.BI_DIM_TIEMPO (anio, cuatrimestre)
	SELECT year([fecha_inicio]), DATEPART(quarter,[fecha_inicio]) from GRAN_EXCEL.[TareasXOrdenes]
	UNION 
	SELECT year([fecha_fin]), DATEPART(quarter,[fecha_fin]) from GRAN_EXCEL.[TareasXOrdenes]

--DIMENSION CAMION
CREATE TABLE GRAN_EXCEL.BI_DIM_CAMION (

	[id_camion] INT PRIMARY KEY, 
	[patente] NVARCHAR(255) NOT NULL,
	[nro_chasis] NVARCHAR(255) NOT NULL,
	[nro_motor] NVARCHAR(255) NOT NULL,
	[fecha_alta] DATETIME2(3) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_CAMION([id_camion], [patente], [nro_chasis], [nro_motor],[fecha_alta])
	SELECT [id_camion], [patente], [nro_chasis], [nro_motor],[fecha_alta] from GRAN_EXCEL.[Camiones]

--DIMENSION MARCAS
CREATE TABLE GRAN_EXCEL.BI_DIM_MARCA(
	[id_marca] INT IDENTITY(1,1) PRIMARY KEY,
	[descripcion] NVARCHAR(255) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_MARCA([descripcion])
	SELECT [id_marca] from GRAN_EXCEL.[Marcas]

--DIMENSION MODELOS
CREATE TABLE GRAN_EXCEL.BI_DIM_MODELO(
	[id_modelo] INT PRIMARY KEY,
	[camion] NVARCHAR(255) NOT NULL,
	[velocidad_max] INT NOT NULL,
	[capacidad_tanque] INT NOT NULL,
	[capacidad_carga] INT NOT NULL
	--[id_marca] INT NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_MODELO([id_modelo], [camion], [velocidad_max], [capacidad_tanque], [capacidad_carga], [id_marca])
	SELECT [id_modelo], [camion], [velocidad_max], [capacidad_tanque], [capacidad_carga], [id_marca] FROM GRAN_EXCEL.[Modelos]

--DIMENSION TALLER
CREATE TABLE GRAN_EXCEL.BI_DIM_TALLER(
	[id_taller] INT PRIMARY KEY, 
	[nombre] NVARCHAR(255) NOT NULL,
	[telefono] DECIMAL(18,0) NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
)


INSERT INTO GRAN_EXCEL.BI_DIM_TALLER ([id_taller], [nombre], [telefono], [direccion], [mail]) 
	SELECT [id_taller], [nombre], [telefono], [direccion], [mail] FROM GRAN_EXCEL.[Talleres]

--DIMENSION TIPO_TAREA
CREATE TABLE GRAN_EXCEL.BI_DIM_TIPO_TAREA(
	[id_tipo_tarea] INT PRIMARY KEY,
	[descripcion] NVARCHAR(255) NOT NULL,
)


INSERT INTO GRAN_EXCEL.BI_DIM_TIPO_TAREA ([id_tipo_tarea], [descripcion]) 
	SELECT [id_tipo_tarea], [descripcion] FROM GRAN_EXCEL.[Tipos_tareas]

--DIMENSION RECORRIDO
CREATE TABLE GRAN_EXCEL.BI_DIM_RECORRIDO (
	[id_recorrido] INT PRIMARY KEY,
	[km] INT		NOT NULL,
	[precio] DECIMAL(18,2)	NOT NULL,
	[id_ciudad_origen] NVARCHAR(100) NOT NULL,
	[id_ciudad_destino] NVARCHAR(100) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_RECORRIDO ([id_recorrido], [km], [precio], [id_ciudad_origen], [id_ciudad_destino]) 
	SELECT [id_recorrido], [km], [precio], 
		(SELECT [nombre] FROM GRAN_EXCEL.[Ciudades] c WHERE r.[id_ciudad_origen] = c.[id_ciudad]), 
		(SELECT [nombre] FROM GRAN_EXCEL.[Ciudades] c WHERE r.[id_ciudad_destino] = c.[id_ciudad])
	FROM [GRAN_EXCEL].[Recorridos] r

--DIMENSION CHOFER
CREATE TABLE GRAN_EXCEL.BI_DIM_CHOFER(
	[nro_legajo]	INT PRIMARY KEY,
	[nombre] NVARCHAR(255)	NOT NULL,
	[apellido] NVARCHAR(255)	NOT NULL,
	[dni] DECIMAL(18,0)		NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[telefono] INT			NOT NULL,
	[mail] NVARCHAR(255)		NOT NULL,
	[fecha_nacimiento] DATETIME2(3)	NOT NULL,
	[costo_hora] INT			NOT NULL,
	rango_edad NVARCHAR(10) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_CHOFER
	([nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], rango_edad) 
	SELECT  
	[nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], rango_edad, GRAN_EXCEL.getAgeRange([fecha_nacimiento]) 
	FROM GRAN_EXCEL.[Choferes]

--DIMENSION MECANICO
CREATE TABLE GRAN_EXCEL.BI_DIM_MECANICO(
	[nro_legajo] INT PRIMARY KEY,
	[nombre] NVARCHAR(255) NOT NULL,
	[id_taller] INT NOT NULL,
	[apellido] NVARCHAR(255) NOT NULL,
	[dni] DECIMAL(18,0) NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[telefono] INT NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
	[fecha_nacimiento] DATETIME2(3) NOT NULL,
	[costo_hora] INT NOT NULL,
	rango_edad NVARCHAR(10) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MECANICO
	([nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], rango_edad) 
	SELECT  
	[nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], rango_edad, GRAN_EXCEL.getAgeRange(fecha_nacimiento) 
	FROM GRAN_EXCEL.[Mecanicos]

--DIMENSION MATERIAL (agregada)
CREATE TABLE GRAN_EXCEL.BI_DIM_MATERIAL (
    material_id INT PRIMARY KEY,
	material_cod NVARCHAR(100) NOT NULL,
    material_descripcion NVARCHAR(255) NOT NULL,
    precio DECIMAL(18, 2) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MATERIAL (material_id, material_cod, material_descripcion, precio)
	SELECT material_id, material_cod, material_descripcion, precio FROM GRAN_EXCEL.Material

--DIMENSION VIAJE_X_PAQUETE (Agregada)
CREATE TABLE GRAN_EXCEL.BI_DIM_VIAJE_X_PAQUETE (
    [id_viaje] INT,
	[id_paquetes_x_viaje] INT,
    [cantidad] INT NOT NULL,
	[id_tipo_paquete] INT NOT NULL,
    [precioTotal] DECIMAL(18, 2) NOT NULL,
	PRIMARY KEY ([id_paquetes_x_viaje])
)

INSERT INTO GRAN_EXCEL.BI_DIM_VIAJE_X_PAQUETE ([id_viaje], [id_paquetes_x_viaje], [cantidad], [precioTotal])
	SELECT [id_viaje], [id_paquetes_x_viaje], [cantidad], [precioTotal] FROM GRAN_EXCEL.[PaquetesXViajes]


--DIMENSION TAREA 
CREATE TABLE GRAN_EXCEL.BI_DIM_TAREA (
	[codigo] INT PRIMARY KEY,
	[descripcion] NVARCHAR(100) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_TAREA ([codigo], [descripcion])
	SELECT [codigo], t.[descripcion]
	FROM GRAN_EXCEL.[Tareas] t
	
