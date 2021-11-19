
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
  [legajo_chof] int,
  [id_reco] int,
  [id_cami] int,
  [id_tiem] int,
  [ingresos] decimal(18,2),
  [consumo] decimal(18,2),
  [tiempoDias] int 
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
	group by tiem_cuatri,id_cami
	
go


IF OBJECT_ID ('GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion; 
GO
create view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion
as
	
	select id_Cami, id_tall, cuatrimestre, sum([cantidad_materiales] * [precio]) + (sum( [costo_hora] * 8 * tiempo_arreglo)/ count(distinct id_mate))  costoTotal
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_tiem = tiem_id
	join GRAN_EXCEL.BI_DIM_MATERIAL on id_mate = mate_id
	join GRAN_EXCEL.BI_DIM_MECANICO on meca_legajo = legajo_meca
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
	join GRAN_EXCEL.BI_DIM_CHOFER c on c.chof_legajo = legajo_chof
	group by [rango_edad_chofer]

go


IF OBJECT_ID ('GRAN_EXCEL.BI_ganancia_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_ganancia_x_camion; 
GO
create view GRAN_EXCEL.BI_ganancia_x_camion
as
	select e.id_cami, sum(e.ingresos) - sum((e.consumo*100)+(e.tiempoDias * 8 * chof_costo_hora)) - sum(mate_cant * mate_precio) + (sum( meca_costoHora * 8 * tiempo_arreglo)/count(distinct mate_id) )ganancia  
	from GRAN_EXCEL.BI_hecho_envio e
	join GRAN_EXCEL.BI_Chofer on e.legajo_chof = chof_legajo
	join GRAN_EXCEL.BI_hecho_arreglo a on a.id_cami = e.id_cami
	join GRAN_EXCEL.BI_Materiales on a.id_mate = mate_id
	join GRAN_EXCEL.BI_Mecanico on meca_legajo = a.legajo_meca
	group by e.id_cami

go