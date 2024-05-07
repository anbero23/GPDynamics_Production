--Production detail with 2 Databases in different Connections

With Detalle_OP_GP16 as (
----------Detalle de OP por item, cantidad, precio unitario y peso unitario
select	b.srcrfrncnmbr Num_OP
		,a.docnumbr
		,a.docdate
		,a.itemnmbr
		,c.itemdesc
		,a.uofm
		,a.trxqty
		,a.unitcost
		,a.extdcost
		,a.trxloctn
		,case left(a.trxloctn,2) when '01' then 'Callao' when '02' then 'Ica' when '03' then 'Piura'
		when '04' then 'Ate' when '07' then 'Chorrillos' else 'N/A' 
		end 'Sede'
		,case b.sourceindicator when 2 then 'Consumo' when 4 then 'Alta' when 3 then 'Consumo-reversa' when 5 then 'Alta-Reversa' 
		 end 'Tipo_OP'
		,case when a.uofm='und' then (case when c.USCATVLS_1='' then 0 else cast(rtrim(c.USCATVLS_1) as decimal(8,3)) end) 
		else case when a.uofm='kg' then 1 else 0 
		end end Peso_und
from dbo.iv30300 a
inner join (select docnumbr,docdate,srcrfrncnmbr,sourceindicator from dbo.iv30200 where srcrfrncnmbr like 'op%') b
on a.docnumbr=b.docnumbr and a.docdate=b.docdate
left dbo.iv00101 c
on a.itemnmbr=c.itemnmbr
--where b.srcrfrncnmbr='op029214'

)

,Detalle_OP_GP13 as (
select	b.srcrfrncnmbr COLLATE Latin1_General_CI_AS Num_OP
		,a.docnumbr COLLATE Latin1_General_CI_AS docnumbr
		,a.docdate
		,a.itemnmbr COLLATE Latin1_General_CI_AS itemnmbr
		,c.itemdesc COLLATE Latin1_General_CI_AS itemdesc
		,a.uofm COLLATE Latin1_General_CI_AS uofm
		,a.trxqty
		,a.unitcost
		,a.extdcost
		,a.trxloctn COLLATE Latin1_General_CI_AS trxloctn
		,case left(a.trxloctn,2) when '01' then 'Callao' when '02' then 'Ica' when '03' then 'Piura'
		when '04' then 'Ate' when '07' then 'Chorrillos' else 'N/A' 
		end 'Sede'
		,case b.sourceindicator when 2 then 'Consumo' when 4 then 'Alta' when 3 then 'Consumo-reversa' when 5 then 'Alta-Reversa' 
		 end 'Tipo_OP'
		,case when a.uofm='und' then (case when c.USCATVLS_1='' then 0 else cast(rtrim(c.USCATVLS_1) as decimal(8,3)) end) 
		else case when a.uofm='kg' then 1 else 0 
		end end Peso_und
from dbo.iv30300 a
inner join (select docnumbr,docdate,srcrfrncnmbr,sourceindicator from GPPER.dbo.iv30200 where srcrfrncnmbr like 'op%') b
on a.docnumbr=b.docnumbr and a.docdate=b.docdate
left join dbo.iv00101 c
on a.itemnmbr=c.itemnmbr
WHERE YEAR(A.DOCDATE)>=2018
----------------------------------------------
)

--,kilos_prod as (
--Select	Num_OP
--		,docnumbr
--		,docdate
--		,sum(trxqty*peso_und) Consumo_kilos
--		,sum(extdcost) Consumo_PEN
--from Detalle_OP 
--where Tipo_OP like 'consumo%'
--group by num_op,docnumbr,docdate
--)

--,kilosprod_OP as (
--Select	a.Num_OP
--		,a.docnumbr
--		,a.docdate
--		,b.Consumo_kilos
--		,b.Consumo_PEN
--from Detalle_OP a
--left join kilos_prod b
--on a.num_op=b.num_op and
--case when a.tipo_OP='Alta' then
--case when substring(a.docnumbr,4,8) in ('','-','.') then '' else convert(decimal(8,0),substring(a.docnumbr,4,8))-1 end
--when a.tipo_OP='Alta-reversa' then
--case when substring(a.docnumbr,4,8) in ('','-','.') then '' else convert(decimal(8,0),substring(a.docnumbr,4,8)) end
--end
--=
--case when a.tipo_OP='Alta' then
--case when substring(b.docnumbr,4,8) in ('','-','.') then '' else convert(decimal(8,0),substring(b.docnumbr,4,8)) end
--when a.tipo_OP='Alta-reversa' then
--case when substring(b.docnumbr,4,8) in ('','-','.') then '' else convert(decimal(8,0),substring(b.docnumbr,4,8))-1 end
--end
----where a.num_op='op029214'
--)

----------------------------------------------
,kilos_altas_GP16 as (
Select	Num_OP
		,docnumbr
		,docdate
		,itemnmbr
		,sum(trxqty*peso_und) Alta_kilos
		,sum(extdcost) Alta_PEN
from Detalle_OP_GP16
where Tipo_OP like 'alta%'
group by num_op,docnumbr,docdate,itemnmbr
)

,kilos_altas_GP13 as (
Select	Num_OP
		,docnumbr
		,docdate
		,itemnmbr
		,sum(trxqty*peso_und) Alta_kilos
		,sum(extdcost) Alta_PEN
from Detalle_OP_GP13
where Tipo_OP like 'alta%'
group by num_op,docnumbr,docdate,itemnmbr
)

----------------------------------------------
,Resumen_OP_GP16 as (
Select	year(a.docdate)*100+month(a.docdate) IdTiempo
		,a.Num_OP
		,a.docnumbr
		,a.docdate
		,a.itemnmbr
		,a.itemdesc
		,a.uofm Und_Medida
		,a.trxqty Cantidad
		,a.Peso_und
		,a.unitcost Cto_Unit_OP
		,case when a.trxqty=0 then 0 else coalesce(c.Alta_PEN/a.trxqty,0) end Cto_Unit_calculado
		,a.extdcost Costo_Alta_OP
		--,b.Consumo_kilos
		,c.Alta_kilos
		--,a.trxqty*peso_und OP_kilos
		--,b.Consumo_PEN
		--,c.Alta_PEN
		,a.Sede
		,a.trxloctn Almacen
from Detalle_OP_GP16 a
--left join kilosprod_OP b 
--on a.Num_OP=b.Num_OP and a.docdate=b.docdate and a.docnumbr=b.docnumbr
left join kilos_altas_GP16 c
on a.Num_OP=c.Num_OP and a.docnumbr=c.docnumbr and a.docdate=c.docdate and a.itemnmbr=c.itemnmbr
where a.Tipo_OP like 'alta%'
)

,Resumen_OP_GP13 as (
Select	year(a.docdate)*100+month(a.docdate) IdTiempo
		,a.Num_OP
		,a.docnumbr
		,a.docdate
		,a.itemnmbr
		,a.itemdesc
		,a.uofm Und_Medida
		,a.trxqty Cantidad
		,a.Peso_und
		,a.unitcost Cto_Unit_OP
		,case when a.trxqty=0 then 0 else coalesce(c.Alta_PEN/a.trxqty,0) end Cto_Unit_calculado
		,a.extdcost Costo_Alta_OP
		--,b.Consumo_kilos
		,c.Alta_kilos
		--,a.trxqty*peso_und OP_kilos
		--,b.Consumo_PEN
		--,c.Alta_PEN
		,a.Sede
		,a.trxloctn Almacen
from Detalle_OP_GP13 a
--left join kilosprod_OP b 
--on a.Num_OP=b.Num_OP and a.docdate=b.docdate and a.docnumbr=b.docnumbr
left join kilos_altas_GP13 c
on a.Num_OP=c.Num_OP and a.docnumbr=c.docnumbr and a.docdate=c.docdate and a.itemnmbr=c.itemnmbr
where a.Tipo_OP like 'alta%'
)
----------------------------------------------
,baseMAQ_GP16 as (
SELECT distinct a.MANUFACTUREORDER_I
				,a.routingname_i
				,a.manufactureorderst_i
				,a.ppn_i
				--,wcid_i
				,max(mrpamount_i) over(partition by a.manufactureorder_i,a.routingname_i,a.ppn_i,a.manufactureorderst_i) maximo
from dbo.pk010033 a
where mrpamount_i>0
)

,MAQ_GP16 as (
Select distinct a.MANUFACTUREORDER_I
				,a.routingname_i
				,a.manufactureorderst_i
				,a.ppn_i
				,b.wcid_i
				,a.maximo
from baseMAQ_GP16 a
left join (select * from dbo.pk010033 a where mrpamount_i>0) b
on a.manufactureorder_i=b.manufactureorder_i and a.routingname_i=b.routingname_i and a.manufactureorderst_i=b.manufactureorderst_i
and a.ppn_i=b.ppn_i and a.maximo=b.mrpamount_i
)

,baseMAQ_GP13 as (
SELECT distinct a.MANUFACTUREORDER_I
				,a.routingname_i
				,a.manufactureorderst_i
				,a.ppn_i
				--,wcid_i
				,max(mrpamount_i) over(partition by a.manufactureorder_i,a.routingname_i,a.ppn_i,a.manufactureorderst_i) maximo
from dbo.pk010033 a
where mrpamount_i>0
)

,MAQ_GP13 as (
Select distinct a.MANUFACTUREORDER_I
				,a.routingname_i
				,a.manufactureorderst_i
				,a.ppn_i
				,b.wcid_i
				,a.maximo
from baseMAQ_GP13 a
left join (select * from dbo.pk010033 a where mrpamount_i>0) b
on a.manufactureorder_i=b.manufactureorder_i and a.routingname_i=b.routingname_i and a.manufactureorderst_i=b.manufactureorderst_i
and a.ppn_i=b.ppn_i and a.maximo=b.mrpamount_i
)

----------------------------------------------
,MaquinaRutina_OP_GP16 as (
Select	a.Num_OP
		,a.itemnmbr
		,b.routingname_i Rutina
		,c.wcdesc_i Maquina
		,case b.manufactureorderst_i
			when 1 then 'Cotizacion'
			when 2 then 'Abierto'
			when 3 then 'Liberado'
			when 4 then 'En espera'
			when 5 then 'Cancelado'
			when 6 then 'Completado'
			when 7 then 'Parcialmente Recibido'
			when 8 then 'Cerrado'
			else 'N/A' end ESTADO
from Resumen_OP_GP16 a
left join MAQ_GP16 b
on a.Num_OP=b.manufactureorder_i and b.ppn_i=a.itemnmbr
left join dbo.wc010931 c
on c.wcid_i=b.wcid_i
)

,MaquinaRutina_OP_GP13 as (
Select	a.Num_OP
		,a.itemnmbr
		,b.routingname_i Rutina
		,c.wcdesc_i Maquina
		,case b.manufactureorderst_i
			when 1 then 'Cotizacion'
			when 2 then 'Abierto'
			when 3 then 'Liberado'
			when 4 then 'En espera'
			when 5 then 'Cancelado'
			when 6 then 'Completado'
			when 7 then 'Parcialmente Recibido'
			when 8 then 'Cerrado'
			else 'N/A' end ESTADO
from Resumen_OP_GP13 a
left join MAQ_GP13 b
on a.Num_OP=b.manufactureorder_i and b.ppn_i=a.itemnmbr
left join dbo.wc010931 c
on c.wcid_i=b.wcid_i
)

----------------------------------------------
,Detalle_Producto as (
Select	distinct a.itemnmbr
		,rtrim(tp.nombre) tipo_proceso
		, rtrim(ln.nombre) linea_negocio
		, rtrim(tf.nombre) familia
		, rtrim(sf.nombre) subfamilia
from (SELECT DISTINCT * FROM (Select distinct case when left(itemnmbr,3)='203' and left(itemdesc,3) not in ('pl ','mer','scr','cel') then concat('1',substring(itemnmbr,2,len(itemnmbr)-1) COLLATE Latin1_General_CI_AS) else itemnmbr end itemnmbr2,itemnmbr
from Resumen_OP_GP16 
union all Select distinct case when left(itemnmbr,3)='203' and left(itemdesc,3) not in ('pl ','mer','scr','cel') then concat('1',substring(itemnmbr,2,len(itemnmbr)-1) COLLATE Latin1_General_CI_AS) else itemnmbr end itemnmbr2,itemnmbr
from Resumen_OP_GP13) a) a
		left outer join dbo.nelgtbcategoria tp
on		tp.categoriaid collate Latin1_General_CI_AS = substring(a.itemnmbr2 collate Latin1_General_CI_AS, 1, 1) and tp.empresaid = 'GPPER' 

		left outer join dbo.neLgTbCategoria ln
on		ln.categoriaid collate Latin1_General_CI_AS = substring(a.itemnmbr2 collate Latin1_General_CI_AS, 1, 3) and ln.empresaid = 'GPPER'

		left outer join dbo.nelgtbcategoria tf
on		tf.categoriaid collate Latin1_General_CI_AS = substring(a.itemnmbr2 collate Latin1_General_CI_AS, 1, 5) and tf.empresaid = 'GPPER'

		left outer join dbo.nelgtbcategoria sf
on		sf.categoriaid collate Latin1_General_CI_AS = substring(a.itemnmbr2 collate Latin1_General_CI_AS, 1, 7) and sf.empresaid = 'GPPER' 
)


---------------------------------------------------------------------------------------------------------

select distinct	a.IdTiempo
		,a.Num_OP
		,a.docnumbr
		,a.docdate
		,a.Sede
		,a.Almacen
		,b.locndscr Desc_Almacen
		,a.itemnmbr
		,a.itemdesc
		,a.Und_Medida
		,a.Cantidad
		,a.Peso_und
		,a.Cto_Unit_OP
		,abs(a.Cto_Unit_calculado) Cto_Unit_calculado
		,a.Costo_alta_OP
		--,a.Consumo_kilos
		,a.Alta_kilos --Peso_Teorico
		,c.Maquina
		,c.Rutina
		,c.Estado
		,d.Tipo_proceso
		,d.Linea_negocio
		,d.Familia
		,d.SubFamilia
from Resumen_OP_GP16 a
left join dbo.iv40700 b
on a.Almacen=b.locncode
left join MaquinaRutina_OP_GP16 c
on c.Num_OP=a.Num_OP and c.itemnmbr=a.itemnmbr
left join Detalle_Producto d
on a.itemnmbr=d.itemnmbr
--where year(docdate)*100+month(docdate)<=202006

union all

select distinct	a.IdTiempo
		,a.Num_OP collate Latin1_General_CI_AS
		,a.docnumbr collate Latin1_General_CI_AS
		,a.docdate
		,a.Sede collate Latin1_General_CI_AS
		,a.Almacen collate Latin1_General_CI_AS
		,b.locndscr collate Latin1_General_CI_AS Desc_Almacen
		,a.itemnmbr collate Latin1_General_CI_AS
		,a.itemdesc collate Latin1_General_CI_AS
		,a.Und_Medida collate Latin1_General_CI_AS
		,a.Cantidad
		,a.Peso_und
		,a.Cto_Unit_OP
		,abs(a.Cto_Unit_calculado) Cto_Unit_calculado
		,a.Costo_alta_OP
		--,a.Consumo_kilos
		,a.Alta_kilos --Peso_Teorico
		,c.Maquina collate Latin1_General_CI_AS
		,c.Rutina collate Latin1_General_CI_AS
		,c.Estado collate Latin1_General_CI_AS
		,d.Tipo_proceso collate Latin1_General_CI_AS
		,d.Linea_negocio collate Latin1_General_CI_AS
		,d.Familia collate Latin1_General_CI_AS
		,d.SubFamilia collate Latin1_General_CI_AS
from Resumen_OP_GP13 a
left join dbo.iv40700 b
on a.Almacen=b.locncode
left join MaquinaRutina_OP_GP13 c
on c.Num_OP=a.Num_OP and c.itemnmbr=a.itemnmbr
left join Detalle_Producto d
on a.itemnmbr=d.itemnmbr

