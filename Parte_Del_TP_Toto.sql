
-- TABLAS DE HECHO


CREATE TABLE GRAN_EXCEL.[BI_hecho_arreglo](
  [id_taller] int,
  [id_modelo] int,
  [codigo] int,
  [id_camion] int,
  [nro_legajo] int,
  [id_marca] int,
 -- [id_tiem] int,
  [id_material] nvarchar(100),
 -- [tiempo_arreglo] int,
  [tiempo_estimado] int,
  --[mate_cant] int  
)

insert into GRAN_EXCEL.BI_hecho_arreglo
select distinct [id_taller], md2.[id_modelo], [id_tarea], c2.[id_camion], m1.[nro_legajo], [id_marca], tiem_id, [id_material], otxt_tiempo_real, [tiempo_estimado], [cantidad]
from GRAN_EXCEL.[TareasXOrdenes]
join GRAN_EXCEL.BI_DIM_TIPO_TAREA on-- tare_id = otxt_tarea
join GRAN_EXCEL.Tarea t1 on t1.tare_id = otxt_tarea
join GRAN_EXCEL.BI_DIM_MECANICO m1 on m1.meca_legajo = otxt_mecanico
join GRAN_EXCEL.[Mecanicos] m on m1.meca_legajo = m.meca_legajo
join GRAN_EXCEL.BI_DIM_TALLER on m.meca_taller = tall_id
join GRAN_EXCEL.BI_DIM_TIEMPO on year(otxt_fecha_inicio) = tiem_anio and DATEPART(quarter,otxt_fecha_inicio) = tiem_cuatri
join GRAN_EXCEL.[Ordenes] on otxt_orden_trabajo = ot_id
join GRAN_EXCEL.[Camiones] c on ot_camion = c.cami_id
join GRAN_EXCEL.BI_DIM_CAMION c2 on c.cami_id = c2.cami_id
join GRAN_EXCEL.[Modelos] md1 on md1.mode_id = c.cami_modelo
join GRAN_EXCEL.BI_DIM_MODELO md2 on md2.mode_id = cami_modelo
join GRAN_EXCEL.BI_DIM_MARCA on md1.mode_marca = marca_nombre
join GRAN_EXCEL.[MaterialesXTareas] on mxt_tarea = otxt_tarea


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
select distinct viaj_chof, viaj_recorrido, viaj_camion, tiem_id, sum(paqx_cantidad * tipa_precio+reco_precio), viaj_consumo_combustible , datediff(day,viaj_fecha_inicio, viaj_fecha_fin)  --Los paso directamente desde la tabla viaje
from GRAN_EXCEL.[Viajes]
join GRAN_EXCEL.BI_DIM_TIEMPO on year(viaj_fecha_inicio) = tiem_anio and DATEPART(quarter,viaj_fecha_inicio) = tiem_cuatri
join GRAN_EXCEL.[PaquetesXViajes] on paqx_viaje = viaj_id
join GRAN_EXCEL.[Tipos_paquetes] on paqx_tipo = tipa_id
join GRAN_EXCEL.[Choferes] on viaj_chof = chof_legajo
join GRAN_EXCEL.BI_DIM_RECORRIDO on viaj_recorrido = reco_id
group by viaj_chof, viaj_recorrido, viaj_camion, tiem_id, viaj_consumo_combustible,viaj_fecha_inicio, viaj_fecha_fin


-- CONSTRAINTS

-- FK HECHO ARREGLO
ALTER TABLE GRAN_EXCEL.BI_hecho_arreglo
ADD CONSTRAINT FK_BI_taller FOREIGN KEY (id_tall) REFERENCES brog.BI_taller(tall_id),
	CONSTRAINT FK_BI_modelo FOREIGN KEY (id_mode) REFERENCES brog.BI_Modelo(mode_id),
	CONSTRAINT FK_BI_tarea FOREIGN KEY (id_tare) REFERENCES brog.BI_tipo_tarea(tare_id),
	CONSTRAINT FK_BI_camion FOREIGN KEY (id_cami) REFERENCES brog.BI_camion(cami_id),
	CONSTRAINT FK_BI_mecanico FOREIGN KEY (legajo_meca) REFERENCES brog.BI_mecanico(meca_legajo),
	CONSTRAINT FK_BI_marca FOREIGN KEY (id_marca) REFERENCES brog.BI_marca(marca_id),
	CONSTRAINT FK_BI_tiempo FOREIGN KEY (id_tiem) REFERENCES brog.BI_tiempo(tiem_id),
	CONSTRAINT FK_BI_material FOREIGN KEY (id_mate) REFERENCES brog.BI_materiales(mate_id)
GO

-- FK HECHO VIAJE
ALTER TABLE GRAN_EXCEL.BI_hecho_envio
ADD CONSTRAINT FK_BI_chofer FOREIGN KEY (legajo_chof) REFERENCES brog.BI_Chofer(chof_legajo),
	CONSTRAINT FK_BI_recorrido FOREIGN KEY (id_reco) REFERENCES brog.BI_Recorrido(reco_id),
	CONSTRAINT FK_BI_camion_viaje FOREIGN KEY (id_cami) REFERENCES brog.BI_Camion(cami_id),
	CONSTRAINT FK_BI_tiempo_viaje FOREIGN KEY (id_tiem) REFERENCES brog.BI_tiempo(tiem_id)
GO

-- VISTAS


IF OBJECT_ID ('GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio; 
GO
create view GRAN_EXCEL.BI_maximo_tiempo_fuera_de_servicio
as
	
	select distinct  id_cami Camion , tiem_cuatri Cuatrimestre, max(tiempo_arreglo) tiempoMaximo 
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_tiem = tiem_id
	group by tiem_cuatri,id_cami
	
go


IF OBJECT_ID ('GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion; 
GO
create view GRAN_EXCEL.BI_costo_total_mantenimiento_x_camion
as
	
	select id_Cami, id_tall, tiem_cuatri, sum(mate_cant * mate_precio) + sum( meca_costoHora * 8 * tiempo_arreglo)/ count(distinct id_Tare)  costoTotal
	from GRAN_EXCEL.BI_hecho_arreglo
	join GRAN_EXCEL.BI_DIM_TIEMPO on id_tiem = tiem_id
	join GRAN_EXCEL.BI_DIM_MATERIAL on id_mate = mate_id
	join GRAN_EXCEL.BI_DIM_MECANICO on meca_legajo = legajo_meca
	group by id_cami, id_tall, tiem_cuatri
	--order by tiem_cuatri, id_tall, id_cami
	
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
	--order by sum(mate_cant) desc

go

IF OBJECT_ID ('GRAN_EXCEL.BI_facturacion_total_x_recorrido', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_facturacion_total_x_recorrido; 
GO
create view GRAN_EXCEL.BI_facturacion_total_x_recorrido
as
	select id_Reco, tiem_cuatri, sum(ingresos) facturacionTotal from GRAN_EXCEL.BI_hecho_envio
	join GRAN_EXCEL.BI_DIM_TIEMPO on tiem_id = id_tiem
	group by id_reco, tiem_cuatri 

go

IF OBJECT_ID ('GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes; 
GO
create view GRAN_EXCEL.BI_costo_promedio_x_rango_etario_de_choferes
as
	select (select sum(chof_costo_hora) from GRAN_EXCEL.BI_DIM_CHOFER where chof_rango_edad = c.chof_rango_edad)/ count(distinct chof_legajo) costo, chof_rango_edad from GRAN_EXCEL.BI_hecho_envio
	join GRAN_EXCEL.BI_DIM_CHOFER c on c.chof_legajo = legajo_chof
	group by chof_rango_edad

go


IF OBJECT_ID ('GRAN_EXCEL.BI_ganancia_x_camion', 'V') IS NOT NULL  
   DROP view GRAN_EXCEL.BI_ganancia_x_camion; 
GO
create view GRAN_EXCEL.BI_ganancia_x_camion
as
	select e.id_cami, sum(e.ingresos) - sum((e.consumo*100)+(e.tiempoDias * 8 * chof_costo_hora)) - sum(mate_cant * mate_precio) + sum( meca_costoHora * 8 * tiempo_arreglo) ganancia  
	from GRAN_EXCEL.BI_hecho_envio e
	join GRAN_EXCEL.BI_DIM_CHOFER on e.legajo_chof = chof_legajo
	join GRAN_EXCEL.BI_hecho_arreglo a on a.id_cami = e.id_cami
	join GRAN_EXCEL.BI_DIM_MATERIAL on a.id_mate = mate_id
	join GRAN_EXCEL.BI_DIM_MECANICO on meca_legajo = a.legajo_meca
	group by e.id_cami

go