
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

/*Obtener toda la informacion de ProveerAlimento, donde los proveedores suministren alimento
 y medicina en el mismo Bioma*/
SELECT PAM.*
FROM ProveerAlimento PA
JOIN ProveerMedicina PAM ON PA.RFCProveedor = PAM.RFCProveedor
JOIN DistribuirAlimento DA ON PA.IDInsumoAlimento = DA.IDInsumoAlimento
JOIN DistribuirMedicina DM ON PAM.IDInsumoMedicina = DM.IDInsumoMedicina
WHERE DA.IDBioma = DM.IDBioma;


-- Seleccionar el tipo de bioma, la especie y contar la cantidad de animales por especie en cada bioma
SELECT b.TipoBioma, a.Especie, COUNT(*) AS CantidadAnimales
FROM Animal a
JOIN Bioma b ON a.IDBioma = b.IDBioma
GROUP BY b.TipoBioma, a.Especie;

-- Calcular la edad promedio de los visitantes por género
SELECT Genero, AVG(EXTRACT(YEAR FROM AGE(FechaNacimiento))) AS EdadPromedio
FROM Visitante
GROUP BY Genero;

-- Calcular el salario promedio de los cuidadores por especie de animal a cargo
SELECT c.Especie, AVG(tc.Salario) AS SalarioPromedio
FROM Cuidar c
JOIN Cuidador tc ON c.RFCCuidador = tc.RFCCuidador
GROUP BY c.Especie;

-- El tipo más frecuente de evento a los que asisten las personas de 20 a 24 años, además de mostrar la cantidad de éstas personas que han asistido a éste tipo de evento
SELECT tipoevento, count(tipoevento) as cantidad
FROM (SELECT idevento
      FROM Visitante NATURAL JOIN Visitar
      WHERE AGE(FechaNacimiento) BETWEEN interval '20 years' and interval '24 years')
	  NATURAL JOIN evento
GROUP BY tipoevento
ORDER BY cantidad DESC
LIMIT 1;

-- Obtener la cantidad se tickets de servicios de comida generados por año y por trimestre, ordenados por año y trimestre

SELECT count(numticket), EXTRACT('year' FROM fecha) AS año,
       EXTRACT('quarter' from fecha) as trimestre
FROM ticket
WHERE LOWER(tiposervicio) = 'comida'
GROUP BY año, trimestre
ORDER BY año;

--Obtener el directorio (nombre, apellidos, teléfono y correo) de los cuidadores cuyo nombre o apellidos contengan la cadena "or" y que trabajen en el aviario
SELECT nombre, apellidopaterno, apellidomaterno, telefono, correo
FROM
(SELECT idbioma, nombre, apellidopaterno, apellidomaterno, telefono, correo
FROM Cuidador NATURAL JOIN TelefonoCuidador NATURAL JOIN CorreoCuidador
WHERE (LOWER(nombre) LIKE '%or%' OR LOWER(apellidopaterno) LIKE '%or%'
      OR LOWER(apellidomaterno) LIKE '%or%')) NATURAL JOIN Bioma
WHERE LOWER(tipobioma) = 'aviario';



