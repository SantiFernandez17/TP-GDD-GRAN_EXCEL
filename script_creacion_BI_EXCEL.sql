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
	anio SMALLDATETIME, -- o int not null
	cuatrimestre INT NOT NULL
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
	[rango_edad_chofer] nvarchar(255) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_CHOFER
	([nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], [rango_edad_chofer]) 
	SELECT  
	[nro_legajo], [nombre], [apellido], [dni], [direccion], [telefono], [mail], [fecha_nacimiento], [costo_hora], [rango_edad_chofer], GRAN_EXCEL.getAgeRange([fecha_nacimiento]) 
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
    [id_material] INT PRIMARY KEY,
	[codigo] NVARCHAR(100) NOT NULL,
    [descripcion] NVARCHAR(255) NOT NULL,
    [precio] DECIMAL(18, 2) NOT NULL,
	[cantidad_materiales] decimal(18,2) not null,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MATERIAL ([id_material], [codigo], [descripcion], [precio])
	SELECT [id_material], [codigo], [descripcion], [precio], [cantidad_materiales] FROM GRAN_EXCEL.[Materiales]

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








	
-- TABLAS DE HECHO


CREATE TABLE GRAN_EXCEL.[BI_hecho_arreglo](
  [id_taller] int,
  [id_modelo] int,
  [codigo] int,
  [id_camion] int,
  [nro_legajo] int,
  [id_marca] int,
  tiempo_id int,
  [id_material] nvarchar(100),
 -- [tiempo_arreglo] int,
  [tiempo_estimado] int,
  --[mate_cant] int  creo que es [cantidad] de paquetes
)

insert into GRAN_EXCEL.BI_hecho_arreglo
select distinct [id_taller], md2.[id_modelo], [id_tarea], c2.[id_camion], m1.[nro_legajo], [id_marca], tiempo_id, [id_material], [tiempo_real_dias], [tiempo_estimado], [cantidad]
from GRAN_EXCEL.[TareasXOrdenes]
join GRAN_EXCEL.BI_DIM_TIPO_TAREA on [codigo] = [id_tarea]
join GRAN_EXCEL.[Tareas] t1 on t1.[codigo] = [id_tarea]
join GRAN_EXCEL.BI_DIM_MECANICO m1 on m1.[nro_legajo] = [legajo_mecanico]
join GRAN_EXCEL.[Mecanicos] m on m1.[nro_legajo] = m.[nro_legajo]
join GRAN_EXCEL.BI_DIM_TALLER on m.[id_taller] = [id_taller]
join GRAN_EXCEL.BI_DIM_TIEMPO on year([fecha_inicio]) = tiem_anio and DATEPART(quarter,otxt_fecha_inicio) = tiem_cuatri
join GRAN_EXCEL.[Ordenes] on [id_orden] = [nro_trabajo]
join GRAN_EXCEL.[Camiones] c on [id_camion] = c.[id_camion]
join GRAN_EXCEL.BI_DIM_CAMION c2 on c.[id_camion] = c2.[id_camion]
join GRAN_EXCEL.[Modelos] md1 on md1.[id_modelo] = c.[id_modelo]
join GRAN_EXCEL.BI_DIM_MODELO md2 on md2.[id_modelo] = [id_modelo]
join GRAN_EXCEL.BI_DIM_MARCA on md1.[id_marca] = [id_marca]
join GRAN_EXCEL.[MaterialesXTareas] on [id_tarea] = [id_tarea]


CREATE TABLE GRAN_EXCEL.[BI_hecho_envio](
  [nro_legajo] int,
  [id_recorrido] int,
  [id_camion] int,
  tiempo_id int,
  [ingresos] decimal(18,2), -- nose
  [consumo] decimal(18,2), -- creo que es [consumo_combustible]
  [tiempoDias] int -- nose
)

insert into GRAN_EXCEL.BI_hecho_envio
select distinct [legajo_chofer_designado] , [id_recorrido], [id_camion_designado], tiempo_id, sum([cantidad] * [precio]+[precio]), [consumo_combustible] , datediff(day,[fecha_inicio], [fecha_fin])  --Los paso directamente desde la tabla viaje
from GRAN_EXCEL.[Viajes]
join GRAN_EXCEL.BI_DIM_TIEMPO on year([fecha_inicio]) = anio and DATEPART(quarter,[fecha_inicio]) = cuatrimestre
join GRAN_EXCEL.[PaquetesXViajes] on [id_viaje] = [id_viaje]
join GRAN_EXCEL.[Tipos_paquetes] on [id_tipo_paquete] = [id_tipo]
join GRAN_EXCEL.[Choferes] on [nro_legajo] = [nro_legajo]
join GRAN_EXCEL.BI_DIM_RECORRIDO on [id_recorrido] = [id_recorrido]
group by [legajo_chofer_designado], [id_recorrido], [id_camion_designado], tiem_id, [consumo_combustible],[fecha_inicio] , [fecha_fin] 


-- CONSTRAINTS

-- FK HECHO ARREGLO
ALTER TABLE GRAN_EXCEL.BI_hecho_arreglo
ADD CONSTRAINT FK_BI_DIM_TALLER FOREIGN KEY ([id_taller]) REFERENCES GRAN_EXCEL.BI_DIM_TALLER([id_taller]),
	CONSTRAINT FK_BI_DIM_MODELO FOREIGN KEY ([id_modelo]) REFERENCES GRAN_EXCEL.BI_DIM_MODELO([id_modelo]),
	CONSTRAINT FK_BI_DIM_TAREA FOREIGN KEY ([codigo]) REFERENCES GRAN_EXCEL.BI_DIM_TIPO_TAREA([id_tipo_tarea]),
	CONSTRAINT FK_BI_DIM_CAMION FOREIGN KEY ([id_camion]) REFERENCES GRAN_EXCEL.BI_DIM_CAMION([id_camion]),
	CONSTRAINT FK_BI_DIM_MECANICO FOREIGN KEY ([nro_legajo]) REFERENCES GRAN_EXCEL.BI_DIM_MECANICO([nro_legajo]),
	CONSTRAINT FK_BI_DIM_MARCA FOREIGN KEY ([id_marca]) REFERENCES GRAN_EXCEL.BI_DIM_MARCA([id_marca]),
	CONSTRAINT FK_BI_DIM_TIEMPO FOREIGN KEY (tiempo_id) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO(tiem_id),
	CONSTRAINT FK_BI_DIM_MATERIAL FOREIGN KEY ([id_material]) REFERENCES GRAN_EXCEL.BI_DIM_MATERIAL([id_material])
GO

-- FK HECHO VIAJE
ALTER TABLE GRAN_EXCEL.BI_hecho_envio
ADD CONSTRAINT FK_BI_DIM_CHOFER FOREIGN KEY ([nro_legajo]) REFERENCES GRAN_EXCEL.BI_DIM_CHOFER(chof_legajo),
	CONSTRAINT FK_BI_DIM_RECORRIDO FOREIGN KEY ([id_recorrido]) REFERENCES GRAN_EXCEL.BI_DIM_RECORRIDO(reco_id),
	CONSTRAINT FK_BI_camion_viaje FOREIGN KEY ([id_camion]) REFERENCES GRAN_EXCEL.BI_DIM_CAMION(cami_id),
	CONSTRAINT FK_BI_tiempo_viaje FOREIGN KEY (tiempo_id) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO(tiem_id)
GO