
-- Biomas que posean al menos 10 animales.
-- Como solo hay 7 Biomas, la consulta solo devuelve 7 tuplas
SELECT *
FROM Bioma
WHERE IDBioma IN (
    SELECT IDBioma
    FROM Animal
    GROUP BY IDBioma
    HAVING COUNT(*) >= 10
); 

/*Obtener la cantidad total gastada por cada visitante en tickets, considerando descuentos.
  Esta consulta suma el costo total de los tickets en la tabla Visitante, y considera si se 
  aplico algun descuento*/

SELECT IDVisitante, SUM(CostoUnitario - (CostoUnitario * Descuento / 100)) AS TotalGastado
FROM Ticket
GROUP BY IDVisitante;

/*Obtener el ID del evento, el ID del visitante, y el tipo de notificacion de los visitantes que hayan
 sido notificados de un evento, con el tipo de notificacion: EventoPendiente*/
SELECT N.IDEvento, N.IDVisitante, N.TipoNotificacion
FROM Notificar N
JOIN Visitar V ON N.IDVisitante = V.IDVisitante
WHERE N.TipoNotificacion = 'EventoPendiente';

/*Obtener toda la informacion de ProverAlimento, donde los proveedores suministren alimento
 y medicina en el mismo Bioma*/
SELECT PAM.*
FROM ProveerAlimento PA
JOIN ProveerMedicina PAM ON PA.RFCProveedor = PAM.RFCProveedor
JOIN DistribuirAlimento DA ON PA.IDInsumoAlimento = DA.IDInsumoAlimento
JOIN DistribuirMedicina DM ON PAM.IDInsumoMedicina = DM.IDInsumoMedicina
WHERE DA.IDBioma = DM.IDBioma;



