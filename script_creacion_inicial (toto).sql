use GD2C2021
GO
/****** Object:  Schema [brog]    Script Date: 10/04/2019 1:55:37 ******/
CREATE SCHEMA [brog]
GO


CREATE TABLE [brog].[Materiales] (
  [mate_id] nvarchar(100),
  [mate_descripcion] nvarchar(255) NULL,
  [mate_precio] decimal(18,2) NULL,
  CONSTRAINT PK_Materiales PRIMARY KEY ([mate_id])
)


CREATE TABLE [brog].[Tarea] (
  [tare_id] int identity(1,1),
  [tarea_tipo] nvarchar(255) NULL,
  [tarea_tiempo_estimado] int NULL,
  CONSTRAINT PK_Tarea PRIMARY KEY ([tare_id])
)




CREATE TABLE [brog].[Taller] (
  [tall_id] int identity(1,1),
  [tall_direccion] nvarchar(255) NULL,
  [tall_telefono] decimal(18,0) NULL,
  [tall_mail] nvarchar(255) NULL,
  [tall_nombre] nvarchar(255) NULL,
  [tall_ciudad] nvarchar(255) NULL,
  CONSTRAINT PK_Taller PRIMARY KEY ([tall_id])
)


CREATE TABLE [brog].[Recorrido] (
  [reco_id] int identity(1,1),
  [reco_ciudad_dest] nvarchar(255) NULL,
  [reco_ciudad_origen] nvarchar(255) NULL,
  [reco_precio] decimal(18,2) NULL,
  [reco_km] int NULL,
  CONSTRAINT PK_Recorrido PRIMARY KEY ([reco_id])
)



CREATE TABLE [brog].[Tipo_paquete] (
  [tipa_id] int identity(1,1),
  [tipa_descripcion] nvarchar(255) NULL,
  [tipa_peso_max] decimal(18,2) NULL,
  [tipa_alto_max] decimal(18,2) NULL,
  [tipa_ancho_max] decimal(18,2) NULL,
  [tipa_largo_max] decimal(18,2) NULL,
  [tipa_precio] decimal(18,2) NULL,
  CONSTRAINT PK_Tipo_paquete PRIMARY KEY ([tipa_id])
)

CREATE TABLE [brog].[Chofer] (
  [chof_id] int identity(1,1),
  [chof_nombre] nvarchar(255) NULL,
  [chof_apellido] nvarchar(255) NULL,
  [chof_direccion] nvarchar(255) NULL,
  [chof_mail] nvarchar(255) NULL,
  [chof_legajo] int NULL,
  [chof_dni] decimal(18,0) NULL,
  [chof_telefono] int NULL,
  [chof_fecha_nac] datetime2(3) NULL,
  [chof_costo_hora] int NULL,
  CONSTRAINT PK_Chofer PRIMARY KEY ([chof_id])
)

CREATE TABLE [brog].[Modelo] (
  [mode_id] int identity(1,1),
  [mode_velocidad_max] int NULL,
  [mode_capacidad_tanque] int NULL,
  [mode_capacidad_carga] int NULL,
  [mode_nombre] nvarchar(255) NULL,
  [mode_marca] nvarchar(255) NULL,
  CONSTRAINT PK_Modelo PRIMARY KEY ([mode_id])
)


CREATE TABLE [brog].[Camion] (
  [cami_id] int identity(1,1),
  [cami_patente] nvarchar(255) NULL,
  [cami_nro_chasis] nvarchar(255) NULL,
  [cami_nro_motor] nvarchar(255) NULL,
  [cami_fecha_alta] datetime2(3) NULL,
  [cami_modelo] int,
  CONSTRAINT PK_Camion PRIMARY KEY ([cami_id]),
  CONSTRAINT FK_Camion FOREIGN KEY (cami_modelo) REFERENCES brog.Modelo(mode_id)
)


CREATE TABLE [brog].[Orden_trabajo] (
  [ot_id] int identity(1,1),
  [ot_camion] int,
  [ot_fecha_realizacion] nvarchar(255) NULL,
  CONSTRAINT PK_Orden_trabajo PRIMARY KEY ([ot_id]),
  CONSTRAINT FK_Orden_trabajo FOREIGN KEY (ot_camion) REFERENCES brog.Camion(cami_id)
)


CREATE TABLE [brog].[MaterialesXtarea] (
  [mxt_material] nvarchar(100),
  [mxt_tarea] int NULL,
  [mxt_cantidad] int NULL,
  CONSTRAINT FK_material FOREIGN KEY (mxt_material) REFERENCES brog.Materiales(mate_id),
  CONSTRAINT FK_tarea FOREIGN KEY (mxt_tarea) REFERENCES brog.Tarea(tare_id)
)

CREATE TABLE [brog].[Mecanico] (
  [meca_legajo] int identity(1,1),
  [meca_nombre] nvarchar(255) NULL,
  [meca_apellido] nvarchar(255) NULL,
  [meca_dni] decimal(18,0) NULL,
  [meca_direccion] nvarchar(255) NULL,
  [meca_telefono] int NULL,
  [meca_mail] nvarchar(255) NULL,
  [meca_fechaNac] datetime2(3) NULL,
  [meca_costoHora] int NULL,
  [meca_taller] int NULL,
  CONSTRAINT PK_Mecanico PRIMARY KEY ([meca_legajo]),
  CONSTRAINT FK_Mecanico FOREIGN KEY (meca_taller) REFERENCES brog.Taller(tall_id)
)


CREATE TABLE [brog].[OtXtarea] (
  [otxt_orden_trabajo] int,
  [otxt_tarea] int,
  [otxt_mecanico] int,
  [otxt_estado_tarea] nvarchar(255) NULL,
  [otxt_fecha_inicio_estimada] datetime2(3) NULL,
  [otxt_fecha_inicio] datetime2(3) NULL,
  [otxt_fecha_fin] datetime2(3) NULL,
  [otxt_tiempo_real] int NULL,
  CONSTRAINT FK_OtXorder FOREIGN KEY (otxt_orden_trabajo) REFERENCES brog.Orden_trabajo(ot_id),
  CONSTRAINT FK_OtXtarea FOREIGN KEY (otxt_tarea) REFERENCES brog.Tarea(tare_id),
  CONSTRAINT FK_OtXmecanico FOREIGN KEY (otxt_mecanico) REFERENCES brog.Mecanico(meca_legajo)
)

CREATE TABLE [brog].[Viaje] (
  [viaj_id] int identity(1,1),
  [viaj_camion] int,
  [viaj_chof] int,
  [viaj_recorrido] int,
  [viaj_fecha_inicio] datetime2(7) NULL,
  [viaj_fecha_fin] datetime2(3) NULL,
  [viaj_consumo_combustible] decimal(18,2) NULL,
  CONSTRAINT PK_Viaje PRIMARY KEY ([viaj_id]),
  CONSTRAINT FK_Viaje_camion FOREIGN KEY (viaj_camion) REFERENCES brog.Camion(cami_id),
  CONSTRAINT FK_Viaje_chof FOREIGN KEY (viaj_chof) REFERENCES brog.Chofer(chof_id),
  CONSTRAINT FK_Viaje_recorrido FOREIGN KEY (viaj_recorrido) REFERENCES brog.Recorrido(reco_id)
)


CREATE TABLE [brog].[Paquete] (
  [paqu_id] int identity(1,1),
  [paqu_cantidad] Int NULL,
  [paqu_precio] decimal(18,2) NULL,
  [paqu_viaje] int,
  [paqu_tipo] int,
  CONSTRAINT PK_Paquete PRIMARY KEY ([paqu_id]),
  CONSTRAINT FK_Paquete_viaje FOREIGN KEY (paqu_viaje) REFERENCES brog.Viaje(viaj_id),
  CONSTRAINT FK_Paquete_tipo FOREIGN KEY (paqu_tipo) REFERENCES brog.Tipo_paquete(tipa_id)
)

ALTER TABLE brog.paquete
drop column paqu_peso,paqu_alto,paqu_ancho,paqu_largo,paqu_descripcion


IF OBJECT_ID('migracion','P') IS NOT NULL
DROP PROCEDURE migracion
GO


create procedure brog.migracion 
as
begin

    --MATERIALES
    DECLARE @mate_id nvarchar(100)
    DECLARE @mate_descripcion nvarchar(255)
    DECLARE @mate_precio decimal(18,2)
    
    --TAREA
        
    DECLARE @tarea_tipo nvarchar(255)
    DECLARE @tarea_tiempo_estimado int

    --TALLER

    DECLARE @tall_direccion nvarchar(255) 
    DECLARE @tall_telefono decimal(18,0) 
    DECLARE @tall_mail nvarchar(255) 
    DECLARE @tall_nombre nvarchar(255) 
    DECLARE @tall_ciudad varchar(255) 


    --RECORRIDO

    DECLARE @reco_ciudad_dest nvarchar(255) 
    DECLARE @reco_ciudad_origen nvarchar(255) 
    DECLARE @reco_precio decimal(18,2) 
    DECLARE @reco_km int 




    --TIPA
    DECLARE @tipa_descripcion nvarchar(255) 
    DECLARE @tipa_peso_max decimal(18,2) 
    DECLARE @tipa_alto_max decimal(18,2) 
    DECLARE @tipa_ancho_max decimal(18,2) 
    DECLARE @tipa_largo_max decimal(18,2) 
    DECLARE @tipa_precio decimal(18,2) 



    --CHOFER
    DECLARE @chof_nombre nvarchar(255) 
    DECLARE @chof_apellido nvarchar(255) 
    DECLARE @chof_direccion nvarchar(255) 
    DECLARE @chof_mail nvarchar(255) 
    DECLARE @chof_legajo int 
    DECLARE @chof_dni decimal(18,0) 
    DECLARE @chof_telefono int 
    DECLARE @chof_fecha_nac datetime2(3) 
    DECLARE @chof_costo_hora int 



    --MODELO
	DECLARE @mode_nombre nvarchar(255)
    DECLARE @mode_velocidad_max int 
    DECLARE @mode_capacidad_tanque int 
    DECLARE @mode_capacidad_carga int 
	DECLARE @mode_marca nvarchar(255) 



    --CAMION
    DECLARE @cami_patente nvarchar(255) 
    DECLARE @cami_nro_chasis nvarchar(255) 
    DECLARE @cami_nro_motor nvarchar(255) 
    DECLARE @cami_fecha_alta datetime2(3) 




    --ORDEN DE TRABAJO
    DECLARE @ot_fecha_realizacion nvarchar(255) 

    --MATERIAL POR TAREA
    DECLARE @mxt_cantidad int 


    --MECANICO
    DECLARE @meca_nombre nvarchar(255) 
    DECLARE @meca_apellido nvarchar(255) 
    DECLARE @meca_dni decimal(18,0) 
    DECLARE @meca_direccion nvarchar(255) 
    DECLARE @meca_telefono int 
    DECLARE @meca_mail nvarchar(255) 
    DECLARE @meca_fechaNac datetime2(3) 
    DECLARE @meca_costoHora int 


    --ORDEN X TAREA
    DECLARE @otxt_estado_tarea nvarchar(255) 
    DECLARE @otxt_fecha_inicio_estimada datetime2(3) 
    DECLARE @otxt_fecha_inicio datetime2(3) 
    DECLARE @otxt_fecha_fin datetime2(3) 
    --DECLARE @otxt_tiempo_estimado int  --este es el tiempo real asi que no se agrega ahora

    --VIAJE
    DECLARE @viaj_fecha_inicio datetime2(7) 
    DECLARE @viaj_fecha_fin datetime2(3) 
    DECLARE @viaj_consumo_combustible decimal(18,2) 

    --PAQUETE 
    DECLARE @paqu_cantidad Int 



    --DECLARAMOS UN CURSOR QUE NOS SERVIRA PARA MIGRAR LOS DATOS MAS COMODAMENTE
    
    DECLARE migracion_cursor cursor for 
    select MATERIAL_COD,MATERIAL_DESCRIPCION,MATERIAL_PRECIO,
		   TIPO_TAREA,TAREA_TIEMPO_ESTIMADO,
		   TALLER_DIRECCION,TALLER_TELEFONO,TALLER_MAIL,TALLER_NOMBRE,TALLER_CIUDAD,
		   RECORRIDO_CIUDAD_DESTINO,RECORRIDO_CIUDAD_ORIGEN,RECORRIDO_PRECIO,RECORRIDO_KM,
		   PAQUETE_DESCRIPCION, PAQUETE_PESO_MAX, PAQUETE_ALTO_MAX, PAQUETE_ANCHO_MAX, PAQUETE_LARGO_MAX, PAQUETE_PRECIO,
		   CHOFER_NOMBRE, CHOFER_APELLIDO, CHOFER_DIRECCION,CHOFER_MAIL,CHOFER_NRO_LEGAJO,CHOFER_DNI,CHOFER_TELEFONO,CHOFER_FECHA_NAC,CHOFER_COSTO_HORA,
		   MODELO_CAMION,MODELO_VELOCIDAD_MAX,MODELO_CAPACIDAD_TANQUE,MODELO_CAPACIDAD_CARGA,MARCA_CAMION_MARCA,
		   CAMION_PATENTE, CAMION_NRO_CHASIS, CAMION_NRO_MOTOR,CAMION_FECHA_ALTA,
		   ORDEN_TRABAJO_FECHA,
		   --NO SABEMOS COMO ES LO DE MATERIAL CANTIDAD,
		   MECANICO_NOMBRE,MECANICO_APELLIDO,MECANICO_DNI,MECANICO_DIRECCION,MECANICO_TELEFONO,MECANICO_MAIL,MECANICO_FECHA_NAC,MECANICO_COSTO_HORA,
		   ORDEN_TRABAJO_ESTADO, TAREA_FECHA_INICIO_PLANIFICADO, TAREA_FECHA_INICIO, TAREA_FECHA_FIN,
		   VIAJE_FECHA_INICIO,VIAJE_FECHA_FIN,VIAJE_CONSUMO_COMBUSTIBLE,
		   PAQUETE_CANTIDAD
	from gd_esquema.Maestra

	open migracion_cursor 
	fetch next from migracion_cursor into
	  @mate_id, @mate_descripcion,@mate_precio,
      @tarea_tipo, @tarea_tiempo_estimado ,
      @tall_direccion, @tall_telefono , @tall_mail , @tall_nombre , @tall_ciudad ,
      @reco_ciudad_dest , @reco_ciudad_origen ,  @reco_precio ,  @reco_km  ,
      @tipa_descripcion  ,  @tipa_peso_max ,  @tipa_alto_max ,  @tipa_ancho_max ,  @tipa_largo_max ,  @tipa_precio ,
      @chof_nombre  , @chof_apellido  ,  @chof_direccion  ,  @chof_mail  , @chof_legajo ,  @chof_dni ,  @chof_telefono  , @chof_fecha_nac ,  @chof_costo_hora ,
	  @mode_nombre, @mode_velocidad_max  , @mode_capacidad_tanque , @mode_capacidad_carga  , @mode_marca ,
      @cami_patente , @cami_nro_chasis , @cami_nro_motor , @cami_fecha_alta ,
      @ot_fecha_realizacion ,
      @mxt_cantidad ,
	  @meca_nombre , @meca_apellido , @meca_dni ,    @meca_direccion ,  @meca_telefono ,   @meca_mail , @meca_fechaNac , @meca_costoHora  ,
      @otxt_estado_tarea , @otxt_fecha_inicio_estimada , @otxt_fecha_inicio , @otxt_fecha_fin ,
      @viaj_fecha_inicio , @viaj_fecha_fin ,  @viaj_consumo_combustible ,
      @paqu_cantidad 

end











































