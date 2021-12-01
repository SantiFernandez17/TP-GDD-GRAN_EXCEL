USE GD2C2021V2

go

IF OBJECT_ID ('GRAN_EXCEL.BI_hecho_arreglo', 'U') IS NOT NULL  
   DROP TABLE GRAN_EXCEL.BI_hecho_arreglo; 
GO
IF OBJECT_ID ('GRAN_EXCEL.BI_hecho_envio', 'U') IS NOT NULL
   DROP TABLE GRAN_EXCEL.BI_hecho_envio; 
GO
--DROP DE FUNCIONES------------------------------------------------------------

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerEdad')
	DROP FUNCTION GRAN_EXCEL.obtenerEdad

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

--IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_CHOFER')
--DROP TABLE GRAN_EXCEL.BI_DIM_CHOFER

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

IF EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'BI_DIM_MATERIALESXTAREA')
DROP TABLE GRAN_EXCEL.BI_DIM_MATERIALESXTAREA

--CREACIÓN DE FUNCIONES
GO
CREATE FUNCTION GRAN_EXCEL.obtenerEdad (@dateofbirth datetime2(3))
RETURNS varchar(10)												   		
AS
BEGIN
	DECLARE @edad int;
	DECLARE @rango varchar(10);

IF (MONTH(@dateofbirth)!=MONTH(GETDATE()))
	SET @edad = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;
ELSE IF(DAY(@dateofbirth) > DAY(GETDATE()))
	SET @edad = (DATEDIFF(MONTH, @dateofbirth, GETDATE())/12)-1;
ELSE 
	SET @edad = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;

IF (@edad > 17 AND @edad <31)
BEGIN
	SET @rango = '[18-30]';
END
ELSE IF (@edad > 30 AND @edad < 51)
BEGIN
	SET @rango = '[31-50]';
END
ELSE IF(@edad > 50)
BEGIN
	SET @rango = '>50';
END

	RETURN @rango;
END

GO


--Creación y migración de las tablas de las dimensiones


--DIMENSION TIEMPO 
CREATE TABLE GRAN_EXCEL.BI_DIM_TIEMPO(
	tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
	anio SMALLDATETIME, -- o int not null
	cuatrimestre INT NOT NULL
)


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
	[capacidad_carga] INT NOT NULL,
	[id_marca] INT NOT NULL
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
/* 
CREATE TABLE GRAN_EXCEL.BI_DIM_CHOFER(
	[nro_legajo]	INT PRIMARY KEY,
	[costo_hora] INT			NOT NULL,
	[rango_edad_chofer] nvarchar(255) NOT NULL,
) 

INSERT INTO GRAN_EXCEL.BI_DIM_CHOFER
	([nro_legajo], [costo_hora], [rango_edad_chofer] )
	SELECT  
	[nro_legajo], 
	[costo_hora], 
	GRAN_EXCEL.obtenerEdad([fecha_nacimiento]) 
	from GRAN_EXCEL.[Choferes]  
	*/

--DIMENSION MECANICO

/* 
CREATE TABLE GRAN_EXCEL.BI_DIM_MECANICO(
	[nro_legajo] INT PRIMARY KEY,
	[costo_hora] INT NOT NULL,
	[rango_edad] NVARCHAR(10) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MECANICO
	([nro_legajo], [costo_hora], [rango_edad])
	SELECT  
	[nro_legajo], 
	[costo_hora], 
	GRAN_EXCEL.obtenerEdad(fecha_nacimiento) 
	from GRAN_EXCEL.[Mecanicos]

	*/

--DIMENSION MATERIAL
CREATE TABLE GRAN_EXCEL.BI_DIM_MATERIAL (
    [id_material] INT PRIMARY KEY,
	[codigo] NVARCHAR(100) NOT NULL,
    [descripcion] NVARCHAR(255) NOT NULL,
    [precio] DECIMAL(18, 2) NOT NULL,
)

INSERT INTO GRAN_EXCEL.BI_DIM_MATERIAL ([id_material], [codigo], [descripcion], [precio])
	SELECT [id_material], 
	[codigo], 
	[descripcion], 
	[precio]
	from GRAN_EXCEL.[Materiales]

--DIMENSION VIAJE_X_PAQUETE
CREATE TABLE GRAN_EXCEL.BI_DIM_VIAJE_X_PAQUETE (
    [id_viaje] INT,
	[id_paquetes_x_viaje] INT,
    [cantidad] INT NOT NULL,
	[id_tipo_paquete] INT NOT NULL,
	PRIMARY KEY ([id_paquetes_x_viaje])
)

INSERT INTO GRAN_EXCEL.BI_DIM_VIAJE_X_PAQUETE ([id_viaje], [id_paquetes_x_viaje], [cantidad], [id_tipo_paquete])
	SELECT [id_viaje], 
	[id_paquetes_x_viaje], 
	[cantidad],
	[id_tipo_paquete]
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


CREATE TABLE GRAN_EXCEL.BI_DIM_MATERIALESXTAREA(
	[id_materiales_x_tareas] INT IDENTITY(1,1),
	[id_material] INT NOT NULL,
	[id_tarea] INT NOT NULL,
	[cantidad] INT NOT NULL,
	PRIMARY KEY(id_materiales_x_tareas)
)


--DIMENSION RANGO ETARIO
IF OBJECT_ID ('GRAN_EXCEL.BI_DIM_RANGO_ETARIO', 'U') IS NOT NULL  
   DROP TABLE GRAN_EXCEL.BI_DIM_RANGO_ETARIO; 
GO
CREATE TABLE [GRAN_EXCEL].BI_DIM_RANGO_ETARIO(
  [legajo] int NOT NULL,
  [rango_edad] nvarchar(255) NOT NULL,
  CONSTRAINT PK_BI_Rango PRIMARY KEY ([legajo])
)

INSERT INTO GRAN_EXCEL.BI_DIM_RANGO_ETARIO
SELECT [nro_legajo], GRAN_EXCEL.obtenerEdad([fecha_nacimiento]) from GRAN_EXCEL.[Chofer]
union
select [nro_legajo], GRAN_EXCEL.obtenerEdad([fecha_nacimiento]) from GRAN_EXCEL.[Mecanico]




SET IDENTITY_INSERT [GD2C2021V2].[GRAN_EXCEL].[BI_DIM_MATERIALESXTAREA] ON
INSERT INTO GRAN_EXCEL.BI_DIM_MATERIALESXTAREA ([id_materiales_x_tareas], [id_material], [id_tarea], [cantidad])
	SELECT [id_materiales_x_tareas], [id_material], [id_tarea], [cantidad]
	from GRAN_EXCEL.[MaterialesXTareas]
SET IDENTITY_INSERT [GD2C2021V2].[GRAN_EXCEL].[BI_DIM_MATERIALESXTAREA] OFF



-- DESARROLLO DE LAS TABLAS DE HECHO


CREATE TABLE GRAN_EXCEL.[BI_hecho_arreglo](
  [id_del_taller] int,
  [id_de_modelo] int,
  [id_de_tarea] int,
  [id_de_camion] int,
  [legajo_mecanicos] int,
  [id_de_marca] int,
  [id_de_tiempo] int,
  [id_de_materiales] int,
  [tiempo_De_Arreglo] int,
  [tiempoEstimado] int,
  [materiales_cant] int,
  [costo_mantenimiento] decimal(18,2)
)

insert into GRAN_EXCEL.BI_hecho_arreglo
select distinct [id_taller], md1.[id_modelo], txo.[id_tarea], c.[id_camion], m1.[nro_legajo], md1.[id_marca], tiempo_id, [id_material], [tiempo_real_dias], [tiempo_estimado], [cantidad]
,(select SUM(mat.[precio]) + SUM(m.[costo_hora])*[tiempo_real_dias]*8 from GRAN_EXCEL.BI_DIM_MATERIALES mat where mat.[id_material] = mat2.[id_material])
from GRAN_EXCEL.[TareasXOrdenes] txo
join GRAN_EXCEL.BI_DIM_TIPO_TAREA  on [id_tarea] = txo.[id_tarea]
join GRAN_EXCEL.[Tareas] t1 on t1.[codigo] = txo.[id_tarea]
join GRAN_EXCEL.BI_DIM_RANGO_ETARIO m1 on m1.[nro_legajo] = [legajo_mecanico]
join GRAN_EXCEL.[Mecanicos] m on m1.[nro_legajo] = m.[nro_legajo]
join GRAN_EXCEL.BI_DIM_TALLER dt on m.[id_taller] = [id_taller]
join GRAN_EXCEL.BI_DIM_TIEMPO  on year([fecha_inicio]) = anio and DATEPART(quarter,[fecha_inicio]) = cuatrimestre
join GRAN_EXCEL.[Ordenes] ord on [id_orden] = [nro_trabajo]
join GRAN_EXCEL.[Camiones] c on ord.[id_camion] = c.[id_camion]
join GRAN_EXCEL.[Modelos] md1 on md1.[id_modelo] = c.[id_modelo]
join GRAN_EXCEL.BI_DIM_MARCA bdm on md1.[id_marca] = bdm.[id_marca]
join GRAN_EXCEL.[MaterialesXTareas] mxt on mxt.[id_tarea] = txo.[id_tarea]
join GRAN_EXCEL.[Materiales] mat2 on mxt.[id_tarea] = txo.[id_tarea]
group by [id_taller], md1.[id_modelo], txo.[id_tarea], c.[id_camion], m1.[nro_legajo], md1.[id_marca], tiempo_id, [id_material], [tiempo_real_dias], [tiempo_estimado], [cantidad], mat2.[id_material]


CREATE TABLE GRAN_EXCEL.[BI_hecho_envio](
  [legajo_chofer] int,
  [id_del_recorrido] int,
  [id_de_camion] int,
  [id_de_tiempo] int,
  [ingresos] decimal(18,2),
  [consumo] decimal(18,2),
  [tiempoEnDias] int 
)

insert into GRAN_EXCEL.BI_hecho_envio
select distinct [legajo], [id_recorrido], [id_camion], tiempo_id, 
(select sum([cantidad] * tp.[precio]) + [precio] from GRAN_EXCEL.[PaquetesXViajes] join GRAN_EXCEL.[Tipos_paquetes] on pxv.[id_tipo_paquete] = [id_tipo] where pxv.[id_viaje] = v.[id_viaje]),
sum([costo_hora])*datediff(day,[fecha_inicio], [fecha_fin])*8 + sum([consumo_combustible])*100
from GRAN_EXCEL.[Viajes] v
join GRAN_EXCEL.BI_DIM_TIEMPO on year([fecha_inicio]) = anio and DATEPART(quarter,[fecha_inicio]) = cuatrimestre
join GRAN_EXCEL.[PaquetesXViajes] pxv on pxv.[id_viaje] = v.[id_viaje]
join GRAN_EXCEL.[Tipos_paquetes] tp on [id_tipo_paquete] = [id_tipo]
join GRAN_EXCEL.[Choferes] on [legajo_chofer_designado] = [nro_legajo]
join GRAN_EXCEL.BI_DIM_RECORRIDO on v.[id_recorrido] = [id_recorrido]
join GRAN_EXCEL.BI_DIM_CAMION on [id_camion] = v.[id_camion_designado]
group by [legajo], v.[id_recorrido], v.[id_camion_designado], tiempo_id,v.[id_viaje],[precio],[fecha_fin],[fecha_inicio],[id_recorrido], [id_camion]

-- DESARROLLO DE CONSTRAINTS

-- FOREIGN KEY DEL HECHO ARREGLO

ALTER TABLE GRAN_EXCEL.BI_hecho_arreglo
ADD CONSTRAINT FK_BI_DIM_TALLER FOREIGN KEY ([id_del_taller]) REFERENCES GRAN_EXCEL.BI_DIM_TALLER([id_taller]),
	CONSTRAINT FK_BI_DIM_MODELO FOREIGN KEY (id_de_modelo) REFERENCES GRAN_EXCEL.BI_DIM_MODELO([id_modelo]),
	CONSTRAINT FK_BI_DIM_TAREA FOREIGN KEY (id_de_tarea) REFERENCES GRAN_EXCEL.BI_DIM_TAREA([codigo]),
	CONSTRAINT FK_BI_DIM_CAMION FOREIGN KEY (id_de_camion) REFERENCES GRAN_EXCEL.BI_DIM_CAMION([id_camion]),
	CONSTRAINT FK_BI_DIM_RANGO_ETARIO FOREIGN KEY (legajo_mecanicos) REFERENCES GRAN_EXCEL.BI_DIM_RANGO_ETARIO([legajo]),
	CONSTRAINT FK_BI_DIM_MARCA FOREIGN KEY (id_de_marca) REFERENCES GRAN_EXCEL.BI_DIM_MARCA([id_marca]),
	CONSTRAINT FK_BI_DIM_TIEMPO FOREIGN KEY (id_de_tiempo) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO([tiempo_id]),
	CONSTRAINT FK_BI_DIM_MATERIAL FOREIGN KEY (id_de_materiales) REFERENCES GRAN_EXCEL.BI_DIM_MATERIAL([id_material])
GO

-- FOREIGN KEY DEL HECHO VIAJE

ALTER TABLE GRAN_EXCEL.BI_hecho_envio
ADD CONSTRAINT FK_BI_DIM_RANGO_ETARIO FOREIGN KEY (legajo_chofer) REFERENCES GRAN_EXCEL.BI_DIM_RANGO_ETARIO([legajo])
	CONSTRAINT FK_BI_DIM_RECORRIDO FOREIGN KEY (id_del_recorrido) REFERENCES GRAN_EXCEL.BI_DIM_RECORRIDO(id_recorrido),
	CONSTRAINT FK_BI_camion_viaje FOREIGN KEY (id_de_camion) REFERENCES GRAN_EXCEL.BI_DIM_CAMION(id_camion),
	CONSTRAINT FK_BI_tiempo_viaje FOREIGN KEY (id_de_tiempo) REFERENCES GRAN_EXCEL.BI_DIM_TIEMPO(tiempo_id)
GO

-- VISTAS


IF OBJECT_ID ('GRAN_EXCEL.BI_tiempo_maximo_fuera_de_servicio', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_tiempo_maximo_fuera_de_servicio; 
GO
create view GRAN_EXCEL.BI_tiempo_maximo_fuera_de_servicio
as
	
	SELECT bc.[patente], bti.cuatrimestre, max(bac.[tiempo_De_Arreglo]) AS 'Tiempo Maximo Fuera de Servicio' 
	FROM GRAN_EXCEL.BI_hecho_arreglo bac
	join GRAN_EXCEL.BI_DIM_TIEMPO bti on bti.tiempo_id = bac.[id_de_tiempo]
	JOIN GRAN_EXCEL.BI_DIM_CAMION bc ON bc.[id_camion] = bac.[id_de_camion]
	group by  bti.cuatrimestre, bac.[id_de_camion], bc.[patente]
	
go

IF OBJECT_ID ('GRAN_EXCEL.BI_costo_total_mantenimiento_por_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_total_mantenimiento_por_camion; 
GO
create view GRAN_EXCEL.BI_costo_total_mantenimiento_por_camion
as
	
	select id_de_camion, [id_del_taller], cuatrimestre, sum([cantidad] * [precio]) + (sum( [costo_hora] * 8 * tiempo_De_Arreglo)/ count(distinct id_de_materiales)) AS 'Costo Total' 
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_de_tiempo = tiempo_id
	join GRAN_EXCEL.BI_DIM_MATERIAL on id_de_materiales = [id_material]
	join GRAN_EXCEL.BI_DIM_MECANICO on [nro_legajo] = legajo_mecanicos
	join GRAN_EXCEL.BI_DIM_MATERIALESXTAREA on [id_tarea] = id_de_tarea
	group by id_de_camion, [id_del_taller], cuatrimestre
	
go


IF OBJECT_ID ('GRAN_EXCEL.BI_desvio_promedio_tarea_por_taller', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_desvio_promedio_tarea_por_taller; 
GO
create view GRAN_EXCEL.BI_desvio_promedio_tarea_por_taller
as
	select id_de_tarea, [id_del_taller], avg(abs(tiempo_De_Arreglo - tiempoEstimado)) AS 'desvio'
	from GRAN_EXCEL.BI_hecho_arreglo	
	group by id_de_tarea, [id_del_taller]

go

IF OBJECT_ID ('GRAN_EXCEL.BI_5_tareas_mas_realizadas_por_modelo_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_5_tareas_mas_realizadas_por_modelo_camion; 
GO
create view GRAN_EXCEL.BI_5_tareas_mas_realizadas_por_modelo_camion
as
	select b.id_de_tarea, b.id_de_modelo
	from GRAN_EXCEL.BI_hecho_arreglo b
	where b.id_de_tarea in (
	select top 5 id_de_tarea 
	from GRAN_EXCEL.BI_hecho_arreglo
	where id_de_modelo = b.id_de_modelo
	group by id_de_modelo, id_de_tarea
	order by count(id_de_tarea) desc
	) 
	group by b.id_de_modelo,b.id_de_tarea

go


IF OBJECT_ID ('GRAN_EXCEL.BI_los_10_materiales_mas_utilizados', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_los_10_materiales_mas_utilizados; 
GO
create view GRAN_EXCEL.BI_los_10_materiales_mas_utilizados
as
	select id_de_materiales, [id_del_taller] from GRAN_EXCEL.BI_hecho_arreglo b
	join GRAN_EXCEL.BI_DIM_MATERIAL on [id_material] = id_de_materiales
	where id_de_materiales in (
	select top 10 id_de_materiales 
	from GRAN_EXCEL.BI_hecho_arreglo 
	where [id_del_taller] = b.[id_del_taller] 
	group by id_de_materiales
	order by sum(materiales_cant) desc
	)
	group by [id_del_taller],id_de_materiales
	

go

IF OBJECT_ID ('GRAN_EXCEL.BI_facturacion_total_por_recorrido', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_facturacion_total_por_recorrido; 
GO
create view GRAN_EXCEL.BI_facturacion_total_por_recorrido
as
	select id_del_recorrido, cuatrimestre, sum(ingresos) AS 'Facturacion Total' 
	from GRAN_EXCEL.BI_hecho_envio
	join GRAN_EXCEL.BI_DIM_TIEMPO on tiempo_id = id_de_tiempo
	group by id_del_recorrido, cuatrimestre 

go

IF OBJECT_ID ('GRAN_EXCEL.BI_costo_promedio_por_rango_etario_de_choferes', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_promedio_por_rango_etario_de_choferes; 
GO
create view GRAN_EXCEL.BI_costo_promedio_por_rango_etario_de_choferes
as
	select (select sum([costo_hora]) from GRAN_EXCEL.[Choferes]) --where [rango_edad] = c.[rango_edad] lo comento porque creo que no va
	/
	count(distinct [nro_legajo]) AS 'Costo',
	[rango_edad] 
	from GRAN_EXCEL.BI_hecho_envio
	JOIN GRAN_EXCEL.BI_DIM_RANGO_ETARIO c on c.[legajo] = [legajo_chofer]
	JOIN GRAN_EXCEL.[Choferes] on [nro_legajo] = c.[legajo]
	group by [rango_edad]

go



IF OBJECT_ID ('GRAN_EXCEL.BI_ganancia_por_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_ganancia_por_camion; 
GO
create view GRAN_EXCEL.BI_ganancia_por_camion
as
	select he.id_de_camion, sum(he.ingresos) - sum(he.[consumo]) - (select sum([costo_mantenimiento]) from GRAN_EXCEL.BI_hecho_arreglo b where b.id_de_camion = he.id_de_camion) AS 'Ganancia' 
	from GRAN_EXCEL.BI_hecho_envio he
	join GRAN_EXCEL.BI_DIM_RANGO_ETARIO on he.legajo_chofer = [legajo]
	--join GRAN_EXCEL.BI_hecho_arreglo a on a.id_de_camion = e.id_de_camion
	--join GRAN_EXCEL.BI_DIM_MATERIAL on a.id_de_materiales = [id_material]
	--join GRAN_EXCEL.BI_DIM_MECANICO bm on bm.[nro_legajo] = a.legajo_mecanicos
	group by he.id_de_camion

go