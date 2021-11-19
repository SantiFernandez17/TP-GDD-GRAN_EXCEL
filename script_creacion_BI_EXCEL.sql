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
	SELECT year([fecha_fin]),
	DATEPART(quarter,[fecha_fin])
	from GRAN_EXCEL.[TareasXOrdenes]

--DIMENSION CAMION
CREATE TABLE GRAN_EXCEL.BI_DIM_CAMION (

	[id_camion] INT PRIMARY KEY, 
	[patente] NVARCHAR(255) NOT NULL,
	[nro_chasis] NVARCHAR(255) NOT NULL,
	[nro_motor] NVARCHAR(255) NOT NULL,
	[fecha_alta] DATETIME2(3) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_CAMION([id_camion], [patente], [nro_chasis], [nro_motor],[fecha_alta])
	SELECT [id_camion],
	[patente],
	[nro_chasis], 
	[nro_motor],
	[fecha_alta] 
	from GRAN_EXCEL.[Camiones]

--DIMENSION MARCAS
CREATE TABLE GRAN_EXCEL.BI_DIM_MARCA(
	[id_marca] INT IDENTITY(1,1) PRIMARY KEY,
	[descripcion] NVARCHAR(255) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_MARCA([descripcion])
	SELECT [id_marca]
	from GRAN_EXCEL.[Marcas]

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
	SELECT [id_modelo],
	[camion], 
	[velocidad_max], 
	[capacidad_tanque], 
	[capacidad_carga], 
	[id_marca] 
	from GRAN_EXCEL.[Modelos]

--DIMENSION TALLER
CREATE TABLE GRAN_EXCEL.BI_DIM_TALLER(
	[id_taller] INT PRIMARY KEY, 
	[nombre] NVARCHAR(255) NOT NULL,
	[telefono] DECIMAL(18,0) NOT NULL,
	[direccion] NVARCHAR(255) NOT NULL,
	[mail] NVARCHAR(255) NOT NULL,
)


INSERT INTO GRAN_EXCEL.BI_DIM_TALLER ([id_taller], [nombre], [telefono], [direccion], [mail]) 
	SELECT [id_taller], 
	[nombre], 
	[telefono], 
	[direccion], 
	[mail] 
	from GRAN_EXCEL.[Talleres]

--DIMENSION TIPO_TAREA
CREATE TABLE GRAN_EXCEL.BI_DIM_TIPO_TAREA(
	[id_tipo_tarea] INT PRIMARY KEY,
	[descripcion] NVARCHAR(255) NOT NULL,
)


INSERT INTO GRAN_EXCEL.BI_DIM_TIPO_TAREA ([id_tipo_tarea], [descripcion]) 
	SELECT [id_tipo_tarea], 
	[descripcion] 
	from GRAN_EXCEL.[Tipos_tareas]

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
	from [GRAN_EXCEL].[Recorridos] r

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
	from GRAN_EXCEL.[Choferes]

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
	from GRAN_EXCEL.[Mecanicos]

--DIMENSION MATERIAL (agregada)
CREATE TABLE GRAN_EXCEL.BI_DIM_MATERIAL (
    [id_material] INT PRIMARY KEY,
	[codigo] NVARCHAR(100) NOT NULL,
    [descripcion] NVARCHAR(255) NOT NULL,
    [precio] DECIMAL(18, 2) NOT NULL,
	[cantidad_materiales] decimal(18,2) not null,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MATERIAL ([id_material], [codigo], [descripcion], [precio])
	SELECT [id_material], 
	[codigo], 
	[descripcion], 
	[precio], 
	[cantidad_materiales] 
	from GRAN_EXCEL.[Materiales]

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
	SELECT [id_viaje], 
	[id_paquetes_x_viaje], 
	[cantidad], 
	[precioTotal] 
	from GRAN_EXCEL.[PaquetesXViajes]


--DIMENSION TAREA 
CREATE TABLE GRAN_EXCEL.BI_DIM_TAREA (
	[codigo] INT PRIMARY KEY,
	[descripcion] NVARCHAR(100) NOT NULL
)

INSERT INTO GRAN_EXCEL.BI_DIM_TAREA ([codigo], [descripcion])
	SELECT [codigo], 
	t.[descripcion]
	from GRAN_EXCEL.[Tareas] t





	

-- TABLAS DE HECHO


CREATE TABLE GRAN_EXCEL.[BI_hecho_arreglo](
  [id_tall] int,
  [id_mode] int,
  [id_tare] int,
  [id_cami] int,
  [legajo_meca] int,
  [id_marca] int,
  [id_tiem] int,
  [id_mate] nvarchar(100),
  [tiempo_arreglo] int,
  [tiempo_estimado] int,
  [mate_cant] int  
)

insert into GRAN_EXCEL.BI_hecho_arreglo
select distinct [id_taller], md1.[id_modelo], [id_tarea], c.[id_camion], m1.[nro_legajo], [id_marca], tiempo_id, [id_material], [tiempo_real_dias], [tiempo_estimado], [cantidad]
from GRAN_EXCEL.[TareasXOrdenes]
join GRAN_EXCEL.BI_DIM_TIPO_TAREA  on [id_tarea] = [id_tarea]
join GRAN_EXCEL.[Tareas] t1 on t1.[id_tarea] = [id_tarea]
join GRAN_EXCEL.BI_DIM_MECANICO m1 on m1.[nro_legajo] = [legajo_mecanico]
join GRAN_EXCEL.[Mecanicos] m on m1.[nro_legajo] = m.[nro_legajo]
join GRAN_EXCEL.BI_DIM_TALLER on m.[id_taller] = [id_taller]
join GRAN_EXCEL.BI_DIM_TIEMPO  on year([fecha_inicio]) = anio and DATEPART(quarter,[fecha_inicio]) = cuatrimestre
join GRAN_EXCEL.[Ordenes] on [id_orden] = [nro_trabajo]
join GRAN_EXCEL.[Camiones] c on [id_camion] = c.[id_camion]
join GRAN_EXCEL.[Modelos] md1 on md1.[id_modelo] = c.[id_modelo]
join GRAN_EXCEL.BI_DIM_MARCA on md1.[id_marca] = [id_modelo]
join GRAN_EXCEL.[MaterialesXTareas] on [id_tarea] = [id_tarea]


CREATE TABLE GRAN_EXCEL.[BI_hecho_envio](
  [legajo_chof] int,
  [id_reco] int,
  [id_cami] int,
  [id_tiem] int,
  [ingresos] decimal(18,2),
  [consumo] decimal(18,2),
  [tiempoDias] int 
)

insert into GRAN_EXCEL.BI_hecho_envio
select distinct [legajo_chofer_designado], [id_recorrido], [id_camion_designado], tiempo_id, sum([cantidad] * [precio]+[precio]), [consumo_combustible] , datediff(day,[fecha_inicio], [fecha_fin])  --Los paso directamente desde la tabla viaje
from GRAN_EXCEL.[Viajes]
join GRAN_EXCEL.BI_DIM_TIEMPO on year([fecha_inicio]) = anio and DATEPART(quarter,[fecha_inicio]) = cuatrimestre
join GRAN_EXCEL.[PaquetesXViajes] on [id_viaje] = [id_viaje]
join GRAN_EXCEL.[Tipos_paquetes] on [id_tipo_paquete] = tipa_id
join GRAN_EXCEL.[Choferes] on [legajo_chofer_designado] = [nro_legajo]
join GRAN_EXCEL.BI_DIM_RECORRIDO  on [id_recorrido] = [id_recorrido]
group by [legajo_chofer_designado], [id_recorrido], [id_camion_designado], tiempo_id, [consumo_combustible],[fecha_inicio], [fecha_fin]


-- CONSTRAINTS

-- FK HECHO ARREGLO
ALTER TABLE GRAN_EXCEL.BI_hecho_arreglo
ADD CONSTRAINT FK_BI_DIM_TALLER FOREIGN KEY (id_tall) REFERENCES GRAN_EXCEL.BI_DIM_TALLER([id_taller]),
	CONSTRAINT FK_BI_DIM_MODELO FOREIGN KEY (id_mode) REFERENCES GRAN_EXCEL.BI_DIM_MODELO([id_modelo]),
	CONSTRAINT FK_BI_DIM_TAREA FOREIGN KEY (id_tare) REFERENCES GRAN_EXCEL.BI_DIM_TIPO_TAREA([id_tipo_tarea]),
	CONSTRAINT FK_BI_DIM_CAMION FOREIGN KEY (id_cami) REFERENCES GRAN_EXCEL.BI_DIM_CAMION([id_camion]),
	CONSTRAINT FK_BI_DIM_MECANICO FOREIGN KEY (legajo_meca) REFERENCES GRAN_EXCEL.BI_DIM_MECANICO([nro_legajo]),
	CONSTRAINT FK_BI_DIM_MARCA FOREIGN KEY (id_marca) REFERENCES GRAN_EXCEL.BI_DIM_MARCA([id_marca]),
	CONSTRAINT FK_BI_DIM_TIEMPO FOREIGN KEY (id_tiem) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO(tiem_id),
	CONSTRAINT FK_BI_DIM_MATERIAL FOREIGN KEY (id_mate) REFERENCES GRAN_EXCEL.BI_DIM_MATERIAL([id_material])
GO

-- FK HECHO VIAJE
ALTER TABLE GRAN_EXCEL.BI_hecho_envio
ADD CONSTRAINT FK_BI_DIM_CHOFER FOREIGN KEY (legajo_chof) REFERENCES GRAN_EXCEL.BI_DIM_CHOFER(chof_legajo),
	CONSTRAINT FK_BI_DIM_RECORRIDO FOREIGN KEY (id_reco) REFERENCES GRAN_EXCEL.BI_DIM_RECORRIDO(reco_id),
	CONSTRAINT FK_BI_camion_viaje FOREIGN KEY (id_cami) REFERENCES GRAN_EXCEL.BI_DIM_CAMION(cami_id),
	CONSTRAINT FK_BI_tiempo_viaje FOREIGN KEY (id_tiem) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO(tiem_id)
GO



-- VISTAS


IF OBJECT_ID ('GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio; 
GO
create view GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio
as
	
	select distinct  id_cami Camion , cuatrimestre Cuatrimestre, max(tiempo_arreglo) tiempoMaximo 
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_tiem = tiempo_id
	group by cuatrimestre ,id_cami
	
go


IF OBJECT_ID ('GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion; 
GO
create view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion
as
	
	select id_Cami, id_tall, cuatrimestre, sum([cantidad_materiales] * [precio]) + (sum( [costo_hora] * 8 * tiempo_arreglo)/ count(distinct id_mate))  costoTotal
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_tiem = tiempo_id
	join GRAN_EXCEL.BI_DIM_MATERIAL on id_mate = [id_material]
	join GRAN_EXCEL.BI_DIM_MECANICO on [nro_legajo] = legajo_meca
	group by id_cami, id_tall, cuatrimestre
	order by cuatrimestre, id_tall, id_cami
	
go


IF OBJECT_ID ('GRAN_EXCEL.BI_desvio_promedio_tarea_x_taller', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_desvio_promedio_tarea_x_taller; 
GO
create view GRAN_EXCEL.BI_desvio_promedio_tarea_x_taller
as
	select id_tare, id_tall, avg(abs(tiempo_arreglo - tiempo_estimado)) desvio from GRAN_EXCEL.BI_hecho_arreglo	
	group by id_tare, id_tall

go

IF OBJECT_ID ('GRAN_EXCEL.BI_5_tareas_mas_realizadas_x_modelo_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_5_tareas_mas_realizadas_x_modelo_camion; 
GO
create view GRAN_EXCEL.BI_5_tareas_mas_realizadas_x_modelo_camion
as
	select b.id_tare, b.id_mode from GRAN_EXCEL.BI_hecho_arreglo b
	where b.id_tare in (select top 5 id_tare 
	                  from GRAN_EXCEL.BI_hecho_arreglo
					  where id_mode = b.id_mode
					  group by id_mode, id_Tare
					  order by count(id_tare) desc) 
	group by b.id_mode,b.id_tare

go


IF OBJECT_ID ('GRAN_EXCEL.BI_10_materiales_mas_utilizados', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_10_materiales_mas_utilizados; 
GO
create view GRAN_EXCEL.BI_10_materiales_mas_utilizados
as
	select id_mate, id_tall from GRAN_EXCEL.BI_hecho_arreglo b
	--join brog.BI_Materiales on mate_id = id_mate
	where id_mate in (select top 10 id_mate 
					  from GRAN_EXCEL.BI_hecho_arreglo 
					  where id_tall = b.id_tall 
					  group by id_mate
					  order by sum(mate_cant) desc )
	group by id_tall,id_mate
	

go

IF OBJECT_ID ('GRAN_EXCEL.BI_facturacion_total_x_recorrido', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_facturacion_total_x_recorrido; 
GO
create view GRAN_EXCEL.BI_facturacion_total_x_recorrido
as
	select id_Reco, cuatrimestre, sum(ingresos) facturacionTotal from GRAN_EXCEL.BI_hecho_envio
	join GRAN_EXCEL.BI_DIM_TIEMPO on tiempo_id = id_tiem
	group by id_reco, cuatrimestre 

go

IF OBJECT_ID ('GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes; 
GO
create view GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes
as
	select (select sum([costo_hora]) from GRAN_EXCEL.BI_DIM_CHOFER where [rango_edad_chofer] = c.[rango_edad_chofer])/ count(distinct [nro_legajo]) costo, [rango_edad_chofer] from GRAN_EXCEL.BI_hecho_envio
	join GRAN_EXCEL.BI_DIM_CHOFER c on c.[nro_legajo] = legajo_chof
	group by [rango_edad_chofer]

go


IF OBJECT_ID ('GRAN_EXCEL.BI_ganancia_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_ganancia_x_camion; 
GO
create view GRAN_EXCEL.BI_ganancia_x_camion
as
	select e.id_cami, sum(e.ingresos) - sum((e.consumo*100)+(e.tiempoDias * 8 * [costo_hora])) - sum(mate_cant * [precio]) + (sum( [costo_hora] * 8 * tiempo_arreglo)/count(distinct [id_material]) ) ganancia  
	from GRAN_EXCEL.BI_hecho_envio e
	join GRAN_EXCEL.BI_DIM_CHOFER on e.legajo_chof = [nro_legajo]
	join GRAN_EXCEL.BI_hecho_arreglo a on a.id_cami = e.id_cami
	join GRAN_EXCEL.BI_DIM_MATERIAL on a.id_mate = [id_material]
	join GRAN_EXCEL.BI_DIM_MECANICO on [nro_legajo] = a.legajo_meca
	group by e.id_cami

go