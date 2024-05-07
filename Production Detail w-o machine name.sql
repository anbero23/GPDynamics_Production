----Producción a detalle sin máquina

with prod_LPP as
(
SELECT YEAR(A.DOCDATE) AS año,
  MONTH(A.DOCDATE) AS mes,
  A.DOCDATE as fecha,
  B.SRCRFRNCNMBR as Num_OP,
  CASE C.MANUFACTUREORDERST_I
when 1 then 'Cotizacion'
when 2 then 'Abierto'
when 3 then 'Liberado'
when 4 then 'En espera'
when 5 then 'Cancelado'
when 6 then 'Completado'
when 7 then 'Parcialmente Recibido'
when 8 then 'Cerrado'
  END as Estado,
  A.TRXLOCTN as planta,
       C.ROUTINGNAME_I as Rutina,
       A.ITEMNMBR as id_articulo,
       D.ITEMDESC as nombre_articulo,
       C.BOMNAME_I as tipo_receta,
       SUM(A.TRXQTY) as unidades,
  SUM(A.TRXQTY*coalesce(F.Kilos, 1)) as kilos
  --E.ACTNUMBR_1,
  --E.ACTDESCR
FROM dbo.IV30300 A --MOVIMIENTOS DE INVENTARIO (DETALLE). SE MUESTRAN CONSUMOS Y ALTAS
LEFT JOIN dbo.IV30200 B ON A.DOCNUMBR = B.DOCNUMBR --MOVIMIENTOS DE INVENTARIO (HEADER). PARA OBTENER EL NÚMERO DE OP ASOCIADA AL MOVIMIENTO
LEFT JOIN dbo.WO010032 C ON B.SRCRFRNCNMBR = C.MANUFACTUREORDER_I --MAESTRO DE OPs. PARA OBTENER LA FECHA, MAQUINA Y ESTADO DE LA OP.
LEFT JOIN dbo.IV00101 D ON A.ITEMNMBR = D.ITEMNMBR --MAESTRO DE ARTÍCULOS. PARA OBTENER EL NOMBRE
LEFT JOIN dbo.GL00100 E ON A.IVIVINDX = E.ACTINDX --MAESTRO DE CUENTAS. PARA OBTENER LOS PT y SE.
LEFT JOIN produccion.LPP.peso_articulos F ON A.ITEMNMBR = F.id_Articulo --MAESTRO DE PESOS.
WHERE B.SRCRFRNCNMBR <> ''
AND E.ACTNUMBR_1 IN ('2312000', '2111000') --PT y SE y planchas
GROUP BY YEAR(A.DOCDATE),
  MONTH(A.DOCDATE),
  A.DOCDATE,
  B.SRCRFRNCNMBR,
  CASE C.MANUFACTUREORDERST_I
when 1 then 'Cotizacion'
when 2 then 'Abierto'
when 3 then 'Liberado'
when 4 then 'En espera'
when 5 then 'Cancelado'
when 6 then 'Completado'
when 7 then 'Parcialmente Recibido'
when 8 then 'Cerrado'
  END,
  A.TRXLOCTN,
       C.ROUTINGNAME_I,
       A.ITEMNMBR,
       D.ITEMDESC,
       C.BOMNAME_I
  --E.ACTNUMBR_1,
  --E.ACTDESCR
)


select a.*
		,b.Linea_Nombre
from prod_LPP a
left join dbo.peru_maestro_articulos b
	on b.codigo=a.id_articulo
WHERE a.id_maquina NOT IN ('GENERACION SCRAP', 'MOLIENDA', '01-21130', '07-21130')


--select * from dbo.WO010032
